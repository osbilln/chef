#!/usr/bin/ruby

if ARGV.count != 4
  puts "db_tables_cloned.rb usage: <db_name> <db_host> <db_user> <db_pw>"
  exit
end

DB_NAME = ARGV[0]
DB_HOST = ARGV[1]
DB_USER = ARGV[2]
DB_PW = ARGV[3]

puts "#{DB_NAME} #{DB_HOST} #{DB_USER} #{DB_PW}"
ALL_TABLES = `echo "show tables from #{DB_NAME};" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`

LOOKUPS = `echo "select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABL
E_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE') and df.purpose = 'LOOKUP_LIST' UNION select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.da
tafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE', 'TMP', 'STAGING',
'EXTENSION') and df.purpose = 'DATA_LIST'" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`
NAEHAS_TABLES = `echo "show tables where tables_in_#{DB_NAME} like 'N\_%' and tables_in_#{DB_NAME} not like 'N\_DATA\_MAPPINGS%';" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s
`
VIEWS = `echo "select table_name from INFORMATION_SCHEMA.tables where table_type = 'VIEW' and table_schema = '#{DB_NAME}'" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`
ACL_TABLES = `echo "show tables where tables_in_#{DB_NAME} like 'acl_%';" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `
ENVERS_AUDIT_TABLES = `echo "show tables where tables_in_#{DB_NAME} like '%\_aud' and tables_in_#{DB_NAME} not like 'N\_%';" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `

TABLES_DUMPED_IN_CLONE = "#{NAEHAS_TABLES} #{ENVERS_AUDIT_TABLES} #{ACL_TABLES} #{LOOKUPS} #{VIEWS}"
TABLES_DUMPED_IN_CLONE.split.each do |table|
  puts "#{table},"
end