#!/usr/bin/ruby

if ARGV.count != 7
  puts "db_tables_from_file_dump.rb usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <tables to dump> <max tables per dump>"
  exit
end

DB_NAME = ARGV[0]
DB_HOST = ARGV[1]
DB_USER = ARGV[2]
DB_PW = ARGV[3]
DUMP_DIR = ARGV[4]
TABLES_TO_DUMP_FILE = ARGV[5]
MAX_TABLES = ARGV[6]

puts "#{DB_NAME} #{DB_HOST} #{DB_USER} #{DB_PW} #{DUMP_DIR} #{TABLES_TO_DUMP_FILE}"

TABLES_TO_DUMP = []
set_cnt = 0
table_cnt = 1
TABLES_TO_DUMP[0] = ""
File.open(TABLES_TO_DUMP_FILE).each do |line|
  line.strip!
  unless line.empty?
    TABLES_TO_DUMP[set_cnt] << line << " " 
    table_cnt += 1
  end
  if table_cnt > MAX_TABLES.to_i
    set_cnt += 1
    table_cnt = 1
    TABLES_TO_DUMP[set_cnt] = ""
  end
end

TABLES_TO_DUMP.each_with_index do |tables_to_dump, index|
  puts "Dumping to #{DUMP_DIR}/#{DB_NAME}_skipped_#{index}.sql.gz"
  `mysqldump --single-transaction --quick --flush-logs -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} #{tables_to_dump} | gzip -1 >  #{DUMP_DIR}/#{DB_NAME}_table_list_#{index}.sql.gz`
end
