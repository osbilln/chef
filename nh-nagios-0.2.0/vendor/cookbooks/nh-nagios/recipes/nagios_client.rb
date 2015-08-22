#
# Cookbook Name:: nh-nagios
# Recipe:: nagios_client
#
# Copyright 2014, Naehas
#
# All rights reserved - Do Not Redistribute
#

node.from_file(run_context.resolve_attribute("nh-nagios", "default"))
include_recipe "nh-nagios::nagios_repo"
case node['platform_family']
when 'debian'
  %w{nagios-nrpe-server nagios-plugins nagios-plugins-basic}.each do |x|
    apt_package "#{x}" do
      action :install
    end
  end
when 'fedora', 'rhel', 'suse'
  %w{nagios-plugins-nrpe nrpe}.each do |x|
    yum_package "#{x}" do
      action :install
    end
  end

else
  Chef::Application.fatal!("Need to customize for OS of #{node[:platform_family]}")
end

include_recipe "nh-nagios::nagios_check"

service node[:nagios][:nrpe_name] do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  subscribes :restart, "template[/etc/nagios/nrpe.cfg]", :delayed
end

# Mark service is enabled
#file "#{node['global']['enabled_services']}/nagios_client" do
#  owner "root"
#  group "root"
#  mode "0755"
#  action :create_if_missing
#end
