#!/usr/bin/ruby1.9.1

require 'aws-sdk'
require 'logger'
require 'json'
require 'date'

# methods

def stop_mysql(ip)
  response = `ssh -o "StrictHostKeyChecking no" ubuntu@#{ip} sudo service mysql stop`
  if response.downcase.include?("error")
    puts "error shutting mysql down on #{ip}: #{response}, exiting"
    exit(1)
  end
end

def start_mysql(ip)
  response = `ssh -o "StrictHostKeyChecking no" ubuntu@#{ip} sudo service mysql start`
  if !response.downcase.include?("start")
    puts "error start mysql on #{ip}: #{response}, exiting"
    exit(1)
  end
end

def scale_up(instance_id, itype)
  response = `{{ app_dir }}/scripts/instance_resize.rb #{instance_id} #{itype}`
  if response.chomp != "success"
    puts "unable to scale up #{instance_id}, response => #{response} exiting"
    exit(1)
  end
end

def promote_slave(ip, password)
  `ssh -o "StrictHostKeyChecking no" ubuntu@#{ip} ./promote_to_master.sh #{password}`
end

def set_master_mycnf(db_host, ip)
  `ssh -o "StrictHostKeyChecking no" ubuntu@#{ip} sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.slave`
  `scp -o "StrictHostKeyChecking no" {{ app_dir }}/config/#{db_host}_master.my.cnf ubuntu@#{ip}:~/#{db_host}_master.my.cnf`
  `ssh -o "StrictHostKeyChecking no" ubuntu@#{ip} sudo cp ~/#{db_host}_master.my.cnf /etc/mysql/my.cnf`
end

def switch_db_host(drweb_host, dashboard_dir, dbhost_new)
  `ssh -o "StrictHostKeyChecking no" naehas@#{drweb_host} "sed -i 's/^dbHost=.*/dbHost=#{dbhost_new}/' /usr/java/#{dashboard_dir}/base-dashboard.properties"`
  `ssh -o "StrictHostKeyChecking no" naehas@#{drweb_host} "/usr/java/#{dashboard_dir}/bin/startup.sh"`
end


## script run starts here

# full DR cutover
# promotes DRDB1 and DRDB2 to master, resizing the instances and promoting mysql to master
# updates the DRWEB instances, resizing them and updating their configs to point to the new master DBs
# 
if ARGV.count < 1
  puts "dr_cutover.rb usage: <mysql password for DRDBs>"
  exit
end

mysql_password = ARGV[0]

# check that the user wants to proceed
puts "You are about to promote the DR infrastructure to be master, are your sure ? [Y|N]"
response = $stdin.gets.chomp.downcase
if response != 'y'
  puts "ok exiting"
  exit(0)
else
  puts "ok proceeding..."
end

puts "update my.cnf on drdb1..."
set_master_mycnf("drdb1", "{{ drdb1.ip }}")

puts "update my.cnf on drdb2..."
set_master_mycnf("drdb2", "{{ drdb2.ip }}")

puts "Stopping mysql on drdb1..."
stop_mysql("{{ drdb1.ip }}")

puts "Stopping mysql on drdb2..."
stop_mysql("{{ drdb2.ip }}")

puts "scaling up drdb1 instance..."
scale_up("{{ drdb1.instance_id }}", "{{ drdb1.itype }}")

puts "scaling up drdb2 instance..."
scale_up("{{ drdb2.instance_id }}", "{{ drdb2.itype }}")

sleep(60)

puts "Promote slave to master on drdb1..."
promote_slave("{{ drdb1.ip }}", mysql_password)

sleep(60)

puts "Promote slave to master on drdb2..."
promote_slave("{{ drdb2.ip }}", mysql_password)

puts "drdb1 and drdb2 fully promoted to master"

puts "scale up drweb1..."
scale_up("{{ drweb1.instance_id }}", "{{ drweb1.itype }}")

puts "switching dr dashboards to drdb1 and drdb2"

{% for (key, value) in drweb1.dashboard_dbhosts.iteritems() %}
puts "switching {{ key }} to {{ value }}"
switch_db_host("{{drweb1.ip}}", "{{ key }}", "{{ value }}")

{% endfor %}

puts "DR cutover complete, test dashboards and then cut DNS over to drweb1"
