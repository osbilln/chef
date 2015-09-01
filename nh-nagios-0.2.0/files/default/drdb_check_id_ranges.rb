#!/usr/bin/ruby

if ARGV.count != 3
    puts "drdb_check_max_ids.rb usage: <repl_db_host> <repl_db_user> <repl_db_pw>"
    exit(1)
end

if !ARGV[0].include?("naehas.net")
    puts "only DNS host names supported for DR databases: #{ARGV[0]}"
    exit(0)
end

REPL_DB_HOST = ARGV[0] 
REPL_DB_USER = MASTER_DB_USER = ARGV[1]
REPL_DB_PW = MASTER_DB_PW = ARGV[2]

if REPL_DB_HOST.include?("drdb1")
    MASTER_DB_HOST = "db8.naehas.net" #internap slave
    dbs = "salesdemo dmiplatform dmiplatform_staging"
else
    MASTER_DB_HOST = "db2.naehas.net" # internap salve
    dbs = "citinew_staging comcastprod comcastprod_staging coxprod coxprod_staging usbankprod usbankprod_staging"
end 

## now loop through the above array
result = ""
dbs.split.each do |db|
    status = `/usr/lib/nagios/plugins/check_id_range.rb #{db} #{REPL_DB_HOST} #{REPL_DB_USER} #{REPL_DB_PW} #{MASTER_DB_HOST} #{MASTER_DB_USER} #{MASTER_DB_PW}`
    #puts "checking ids on #{db} => #{status}"

    if !status.include?("max ids match")
        result += status
    end
end

if result.empty?
    puts "id ranges match between #{REPL_DB_HOST.split('.')[0]} and #{MASTER_DB_HOST.split('.')[0]}"
else
    puts "#{REPL_DB_HOST.split('.')[0]} and #{MASTER_DB_HOST.split('.')[0]} diff: #{result}"
end

exit(0)