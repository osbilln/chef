#!/usr/bin/ruby

if ARGV.count != 7
  puts "check_max_id.rb usage: <db_name> <repl_db_host> <repl_db_user> <repl_db_pw> <master_db_host> <master_db_user> <master_db_pw>"
  exit
end

DB_NAME = ARGV[0]
DB_HOST = ARGV[1]
DB_USER = ARGV[2]
DB_PW = ARGV[3]
DB_MASTER_HOST = ARGV[4]
DB_MASTER_USER = ARGV[5]
DB_MASTER_PW = ARGV[6]

#tables_to_check = `echo "show tables from #{DB_NAME};" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`
tables_to_check = `echo "show tables where tables_in_#{DB_NAME} like 'N\_%' and tables_in_#{DB_NAME} not like 'N\_DATA\_MAPPINGS%' and tables_in_#{DB_NAME} not like 'N\_%\_AUD%';" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `

max_ids = {}

# get max current max id for each table
tables_to_check.split.each do |table| 
  repl_max_id = `echo "select MAX(id) as max_id from #{table};" | mysql -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`.strip
  master_max_id = `echo "select MAX(id) as max_id from #{table};" | mysql -u #{DB_MASTER_USER} -p#{DB_MASTER_PW} -h #{DB_MASTER_HOST} #{DB_NAME} -A -s`.strip
  max_ids[table] = {:repl => repl_max_id, :master => master_max_id}
end

#puts max_ids.inspect

tables_to_check.split.each do |table|
  if max_ids[table][:repl] != max_ids[table][:master]
    put "descrepancy found on #{table} replication max_id => #{max_ids[table][:repl]} master max_id => #{max_ids[table][:repl]}"
    exit(1)
  end
end

puts "max ids match"
exit(0)