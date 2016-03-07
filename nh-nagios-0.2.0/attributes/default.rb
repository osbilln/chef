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

// postfix setup with AWS SES
default[:postfix][:main][:myhostname] = "mail.naehas.net"
default[:postfix][:main][:mydomain] = "naehas.net"
default[:postfix][:main][:myorigin] = "mail.naehas.net"
default[:postfix][:main][:smtp_sasl_auth_enable] = "yes"
default[:postfix][:main][:relayhost] = "email-smtp.us-west-2.amazonaws.com:587"
default[:postfix][:main][:readme_directory] = "no"
default[:postfix][:main][:inet_interfaces] = "loopback-only"
default[:postfix][:main][:smtpd_banner] = "$myhostname ESMTP $mail_name (Ubuntu)"
default[:postfix][:main][:smtp_sasl_password_maps] = "hash:/etc/postfix/sasl_passwd"
default[:postfix][:main][:smtp_tls_security_level] = "encrypt"
default[:postfix][:main][:smtp_tls_note_starttls_offer] = "yes"
default[:postfix][:main][:alias_maps] = "hash:/etc/aliases"
default[:postfix][:main][:alias_database] = "hash:/etc/aliases"
default[:postfix][:main][:recipient_delimiter] = "hash:/etc/aliases"
default[:postfix][:main][:alias_maps] = "+"
default[:postfix][:main][:default_transport] = "smtp"
default[:postfix][:main][:relay_transport] = "smtp"
default[:postfix][:main][:inet_protocols] = "ipv4"
default[:postfix][:main][:smtp_tls_CAfile] = "/etc/ssl/certs/ca-certificates.crt"
default[:postfix][:main][:smtp_generic_maps] = "hash:/etc/postfix/canonical"
default[:postfix][:sasl][:smtp_sasl_passwd] = "AvMwTVyvMKVGcqmtXNuoC62JOX/coVAexpL68YWKeDdm"
default[:postfix][:sasl][:smtp_sasl_user_name] = "AKIAJVJGEDUUS6VR5L4Q"
