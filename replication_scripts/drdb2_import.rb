#!/usr/bin/ruby

# get list of databases to import in s3 bucket, from drdb2 master db7
db_list=`s3cmd ls s3://naehas-operations/backups/db7/ | awk '{ print $4 }'`

dbs = []
db_list.each_line do |line|
  dbs << line.chop.split("/").last if line.include?("sql.gz")
end

dbs.each do |i|
  db_name = i.split(".")[0]
  puts "import #{db_name}"
  system("./db_import.sh #{db_name} localhost root n3admin /data3/dumps naehas-operations/backups/db7")
end







