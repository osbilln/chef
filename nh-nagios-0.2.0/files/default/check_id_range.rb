#!/usr/bin/ruby

if ARGV.count != 8
  puts "check_id_range.rb usage: <db_name> <repl_db_host> <repl_db_user> <repl_db_pw> <master_db_host> <master_db_user> <master_db_pw> <max_diff>"
  exit
end

DB_NAME = ARGV[0]
DB_HOST = ARGV[1]
DB_USER = ARGV[2]
DB_PW = ARGV[3]
DB_MASTER_HOST = ARGV[4]
DB_MASTER_USER = ARGV[5]
DB_MASTER_PW = ARGV[6]
max_diff = ARGV[7].to_i

#tables_to_check = `echo "show tables from #{DB_NAME};" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`
tables_to_check = `echo "show tables where tables_in_#{DB_NAME} like 'N\_%' and tables_in_#{DB_NAME} not like 'N\_DATA\_MAPPINGS%' and tables_in_#{DB_NAME} not like 'N\_%\_AUD%';" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `

if tables_to_check.empty?
  puts "ERROR: unable to get table list, likely due to connection error"
  exit(1)
end

max_ids = {}

# get max current max id for each table
tables_to_check.split.each do |table| 
  id_col = `echo "show columns from #{table} like 'ID';" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`
  if id_col.empty? # skip if no ID column
    repl_max_id = master_max_id = 0
    repl_min_id = master_min_id = 0
  else
    repl_max_id = `echo "select MAX(id) as max_id from #{table};" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`.strip
    repl_min_id = `echo "select MIN(id) as max_id from #{table};" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`.strip
    master_max_id = `echo "select MAX(id) as max_id from #{table};" | mysql -u #{DB_MASTER_USER} -p#{DB_MASTER_PW} -h #{DB_MASTER_HOST} #{DB_NAME} -A -s`.strip
    master_min_id = `echo "select MIN(id) as max_id from #{table};" | mysql -u #{DB_MASTER_USER} -p#{DB_MASTER_PW} -h #{DB_MASTER_HOST} #{DB_NAME} -A -s`.strip
  end  
  max_ids[table] = 
  {
    :repl => { 
      :max_id => repl_max_id == "NULL" ? 0 : repl_max_id.to_i,
      :min_id => repl_min_id == "NULL" ? 0 : repl_min_id.to_i
    }, 
    :master => { 
      :max_id => master_max_id == "NULL" ? 0 : master_max_id.to_i, 
      :min_id => master_min_id == "NULL" ? 0 : master_min_id.to_i
    }
  }
end

#puts max_ids.inspect

output = ""
tables_to_check.split.each do |table|
  if (max_ids[table][:master][:max_id] - max_ids[table][:repl][:max_id] > max_diff) ||
     (max_ids[table][:master][:min_id] - max_ids[table][:repl][:min_id] > max_diff)
    #puts "descrepancy found on #{DB_NAME}.#{table} replication max_id => #{max_ids[table][:repl]} master max_id => #{max_ids[table][:master]}"
    output << "#{DB_NAME}.#{table} "
    # exit(1)
  end
end

if output.empty?    
  puts "max ids match"
else
  puts "#{output}"
end
exit(0)