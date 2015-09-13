%w( httpd mailx git php php-mysql php-gd php-intl php-xml ).each { |e| package e }

# Download icingaweb from github
execute ":: Clone icingaweb2 repo to /usr/share/icingaweb" do
  command "git clone git://git.icinga.org/icingaweb2.git /usr/share/icingaweb"
  not_if { ::File.exists?("/usr/share/icingaweb") }
end

execute ":: Build http config for icinga web 2" do
  command "/usr/share/icingaweb/bin/icingacli setup config webserver apache --document-root /usr/share/icingaweb/public > /etc/httpd/conf.d/icinga.conf"
  not_if { ::File.exists?("/etc/httpd/conf.d/icinga.conf") }
end

execute ":: Create icingaweb2 configuration directory" do
  command "/usr/share/icingaweb/bin/icingacli setup config createDirectory apache"
  not_if { ::File.exists?("/etc/icingaweb") }
end

# Fix php timezone
ruby_block ":: Configure php.ini timezone" do
  block do
    file = Chef::Util::FileEdit.new("/etc/php.ini")
    file.insert_line_if_no_match(/^date.timezone.+/, "date.timezone = UTC")
    file.write_file
  end
end

# Enable additional icinga2 features to fully support IcingaWeb2
%w( command livestatus ).each { |e| icinga2_feature e }

# Add apache to icinga and icingaadm group for 'commands' support
%w( icingacmd icinga ).each do |grp|
  group grp do
    action :modify
    members "apache"
    append true
  end
end

# Distribute config files
template "/etc/icingaweb/resources.ini" do
  source "resources.ini.erb"
  variables({
    :type => node[:icinga2][:backend][:type].to_s,
    :info => node[:icinga2][:backend][node[:icinga2][:backend][:type]]
  })  
  owner "apache"
  group "apache"
  mode 0660
end

%w( authentication.ini config.ini permissions.ini ).each { |f| cookbook_file "/etc/icingaweb/#{f}" }
cookbook_file "/etc/icingaweb/admin-setup.sql"

remote_directory "/etc/icingaweb/modules" do
  owner "apache"
  files_owner "apache"
  group "apache"
  files_group "apache"
  mode 0770
  files_mode 0770
end

# Directory resource
%w( preferences enabledModules ).each do |mod|
  directory "/etc/icingaweb/#{mod}" do
    group "apache"
    mode 0770
    owner "apache"
  end
end

# Link resource
link "/etc/icingaweb/enabledModules/monitoring" do
  to "/usr/share/icingaweb/modules/monitoring"
end

case node[:icinga2][:backend][:type]
when :mysql
  mariadb_database "icingaweb" do
    owner "'#{node[:icinga2][:backend][:mysql][:user]}'@'localhost'"
    action :create
  end

  %w( /usr/share/icingaweb/etc/schema/mysql.schema.sql /etc/icingaweb/admin-setup.sql).each do |schema|
    mariadb_loadsql schema do
      db "icingaweb"
    end
  end
end

# Set icinga2.cmd path
execute "Configure icinga2.cmd" do
  command "find -L /etc/icingaweb -type f -exec sed -i -e 's;/usr/local/icinga/var/rw/icinga.cmd;/var/run/icinga2/cmd/icinga2.cmd;g' {} \\;"
end

# Monitor IcingaWeb instance itself
ruby_block "Configure icingaweb2 monitoring" do
  block do
    file = Chef::Util::FileEdit.new("/etc/icinga2/conf.d/hosts.conf")
    file.insert_line_after_match(/\s*Uncomment if you've sucessfully installed Icinga Web 2/, '  vars.http_vhosts["Icinga Web 2"] = { http_uri = "/icingaweb" }')
    file.write_file
  end
  not_if 'grep -P "[^\/]vars.http_vhosts\[\"Icinga Web 2\"\]" /etc/icinga2/conf.d/hosts.conf'
  notifies :reload, "service[icinga2]", :immediately
end

# Without default index.html icinga will notify http 403.
# just create it.
file "/var/www/html/index.html" do
  not_if { ::File.exists?("/var/www/html/index.html") }
end

service "httpd" do
  action [ :enable, :start ]
end
