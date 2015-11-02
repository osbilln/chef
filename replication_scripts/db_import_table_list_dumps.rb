#!/usr/bin/ruby

if ARGV.count != 4
  puts "db_skipped_in_clone_dump.rb usage: <db_host> <db_user> <db_pw> <dump dir>"
  exit
end

db_host = ARGV[0]
db_user = ARGV[1]
db_pwd = ARGV[2]
dump_dir = ARGV[3]

# get list of databases to import in s3 bucket
Dir.chdir(dump_dir)
db_list = Dir.glob("*_list_*.sql.gz")

db_list.each do |db_file|
  db_name = db_file.split("_table")[0]
  puts "unzipping #{db_file}"
  `gunzip #{db_file}`
  db_file.chomp!(".gz")
  puts "importing into #{db_name}"

  puts "check if database exists, else create it"
  dbexists = `mysql -u #{db_user} -h #{db_host} -p#{db_pwd} --skip-column-names -e "SHOW DATABASES like '${db_name}'"`
    if dbexists.empty?
      puts "creating database $DB_NAME"
      `mysql -u $DB_USER -h $DB_HOST -p$DB_PW -e "create database $DB_NAME"`
    end

 puts "importing #{db_file}"
 `mysql -u #{db_user} -h #{db_host} -p#{db_pwd} #{db_name} < #{db_file}`

 puts "import of #{db_name} complete"
end






