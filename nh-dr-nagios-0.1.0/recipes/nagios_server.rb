#
# Cookbook Name:: nh-nagios
# Recipe:: default
#
# Copyright 2014, 
#
# All rights reserved - Do Not Redistribute
#
node.from_file(run_context.resolve_attribute("nh-nagios", "default"))

include_recipe "nh-nagios::nagios_repo"
########################### Apache Service ###############################
package node[:nagios][:apache_service] do
  action :install
end

service node[:nagios][:apache_service] do
  action :nothing
end
###########################################################################

########################### Nagios Service ################################
# TODO: different node have different role
case node['platform_family']
when 'debian'
  %w{nagios3 nagios-nrpe-plugin}.each do |x|
    apt_package "#{x}" do
      action :install
    end
  end

  user "nagios" do
    gid "www-data"
  end

when 'fedora', 'rhel', 'suse'
  %w{nagios nagios-plugins-all}.each do |x|
    yum_package "#{x}" do
      action :install
    end
  end

else
  Chef::Application.fatal!("Need to customize for OS of #{node[:platform_family]}")
end

# template "/etc/" + node[:nagios][:nagios_name] + "/nagios.cfg" do
#   source "nagios.cfg.erb"
#   owner "root"
#   group "root"
#   mode 0644
#   variables({
#               :check_external_commands => "1"
#             })
# end

directory "/var/lib/nagios3/" do
  mode "0750"
  owner "nagios"
  group "nagios"
  action :create
end

template "/etc/" + node[:nagios][:nagios_name] + "/htpasswd.users" do
  source "htpasswd.users.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
              :nagios_admin_username => node[:nagios][:admin_username],
              :nagios_admin_password_hash => node[:nagios][:admin_password_hash]
            })
  notifies :restart, "service[#{node[:nagios][:apache_service]}]", :delayed
end

service node[:nagios][:nagios_name] do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  #subscribes :restart, "template[/etc/{node[:nagios][:nagios_name]}/nagios.cfg]", :delayed
end
###########################################################################

=begin # MAM shared file system not available so comment this out.
# Mark service is enabled
file "#{node['global']['enabled_services']}/nagios_server" do
  owner "root"
  group "root"
  mode "0755"
  action :create_if_missing
end
=end
