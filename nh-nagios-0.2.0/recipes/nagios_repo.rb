#
# Cookbook Name:: nh-nagios
# Recipe:: nagios_repo
#
# Copyright 2014, 
#
# All rights reserved - Do Not Redistribute
#
case node['platform_family']
when 'fedora', 'rhel', 'suse'
  # TODO: add repo
  # package "remi-release" do
  #   source "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
  #   action :install
  #   provider Chef::Provider::Package::Rpm
  # end
end
