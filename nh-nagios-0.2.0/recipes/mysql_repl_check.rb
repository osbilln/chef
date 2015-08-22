#
# Cookbook Name:: nh-nagios
# Recipe:: mysql_repl_check
#
# All rights reserved - Do Not Redistribute
#

package "mysql-client" do
  action :install
end

cookbook_file "/usr/lib/nagios/plugins/check_mysql_slavestatus.sh" do
  source "check_mysql_slavestatus.sh"
  owner "nagios"
  group "nagios"
  mode "0755"
  action :create
end

cookbook_file "/etc/nagios-plugins/config/mysql_slave_status.cfg" do
  source "mysql_slave_status.cfg"
  owner "nagios"
  group "nagios"
  mode "0644"
  action :create
end

cookbook_file "/etc/nagios3/nagios.cfg" do
  source "nagios.cfg"
  owner "nagios"
  group "nagios"
  mode "0644"
  action :create
end

directory "/etc/nagios3/objects" do
  owner "nagios"
  group "nagios"
  recursive true
  action :create
end

cookbook_file "/etc/nagios3/objects/contacts.cfg" do
  source "contacts.cfg"
  owner "nagios"
  group "nagios"
  mode "0644"
  action :create
end

cookbook_file "/etc/nagios3/objects/mysql_slave_servers.cfg" do
  source "mysql_slave_servers.cfg"
  owner "nagios"
  group "nagios"
  mode "0644"
  action :create
end


service node[:nagios][:nagios_name] do
  supports :status => true, :restart => true, :reload => true
  action [ :restart ]
end
