#!/usr/bin/ruby

if ARGV.count != 6
    puts "drdb1_check_max_ids.rb usage: <repl_db_host> <repl_db_user> <repl_db_pw> <master_db_host> <master_db_user> <master_db_pw>"
    exit(1)
end

if !ARGV[0].include?("naehas.net") || !ARGV[3].include?("naehas.net")
    puts "drdb1_check_max_ids.rb usage: only DNS host names supported"
end

REPL_DB_HOST = ARGV[0] 
REPL_DB_USER = ARGV[1]
REPL_DB_PW = ARGV[2]
MASTER_DB_HOST = ARGV[3]
MASTER_DB_USER = ARGV[4]
MASTER_DB_PW = ARGV[5]

if REPL_DB_HOST.include?("drdb1")
    dbs = "salesdemo dmiplatform dmiplatform_staging"
else
    dbs = "citinew_staging comcastprod comcastprod_staging coxprod coxprod_staging usbankprod usbankprod_staging"
end 

## now loop through the above array
result = ""
dbs.split.each do |db|
    status = `/usr/lib/nagios/plugins/check_max_id.rb #{db} #{REPL_DB_HOST} #{REPL_DB_USER} #{REPL_DB_PW} #{MASTER_DB_HOST} #{MASTER_DB_USER} #{MASTER_DB_PW}`
    #puts "checking ids on #{db} => #{status}"

    if !status.include?("max ids match")
        result += status
    end
end

if result.empty?
    puts "max ids match between #{REPL_DB_HOST.split('.')[0]} and #{MASTER_DB_HOST.split('.')[0]}"
else
    puts "discrepancies: #{result}"
end

exit(0)