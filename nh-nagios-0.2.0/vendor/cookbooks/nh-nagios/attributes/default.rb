default[:nagios][:admin_username] = "nagiosadmin"
default[:nagios][:admin_password_hash] = "$1$GdannYoN$w9cr1N7OhctgqaKDCL.Lg." #password

case node['platform_family']
when 'debian'
  default[:nagios][:apache_service] = "apache2"
  default[:nagios][:nagios_name] = "nagios3"
  default[:nagios][:nrpe_name] = "nagios-nrpe-server"
when 'fedora', 'rhel', 'suse'
  default[:nagios][:apache_service] = "httpd"
  default[:nagios][:nagios_name] = "nagios"
  default[:nagios][:nrpe_name] = "nrpe"
else
  Chef::Application.fatal!("Need to customize for OS of #{node[:platform_family]}")
end
