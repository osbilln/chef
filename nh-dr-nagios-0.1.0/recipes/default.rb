#
# Cookbook Name:: nh-nagios
# Recipe:: default
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "nh-basic-os::update_repo"

# TODO: different node have different role
include_recipe "nh-nagios::nagios_client"
include_recipe "nh-nagios::nagios_check"
# include_recipe "nh-nagios::nagios_server"
