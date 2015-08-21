#
# Cookbook Name:: nh-nagios
# Recipe:: nagios_check
#
# All rights reserved - Do Not Redistribute
#

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
  mode 0755
end

directory "/usr/lib/nagios/plugins" do
  owner "root"
  group "root"
  mode 0755
  recursive true
  action :create
end

template "/usr/lib/nagios/plugins/check_linux_stats.pl" do
  source "check_linux_stats.pl.erb"
  owner "root"
  group "root"
  mode 0755
end
