#
# Cookbook Name:: icinga2
# Recipe:: server
#
# Copyright (C) 2014 Karol@Pasternak.pro
#
# All rights reserved - Do Not Redistribute

=begin

  Install Icinga2 + Web2 on nginx
  this cookbook is about automatically configuring new nodes by searching them
  under chefs postgress database using 'search(:node, "recipe:icinga2::client")'.

=end

# Use internal libraries
class Chef::Recipe
  include Icinga2::Object
end

# Install Icinga2 repository
case node[:platform]
  when "redhat", "centos" then include_recipe "#{cookbook_name}::_yum"
  when "debian", "ubuntu" then include_recipe "#{cookbook_name}::_deb"
end

# Define package to install
packages = %w( icinga2 )

case node[:icinga2][:backend][:type]
when :mysql
  packages << "icinga2-ido-mysql"

  # Create database for cinga backend
  bend = node[:icinga2][:backend][:mysql]

  packages.each { |e| package e }

  icinga2_feature "ido-mysql"

  mariadb_user bend[:user] do
    host "localhost"
    passwd bend[:password]
    action :create
  end

  mariadb_database bend[:db] do
    owner "'#{bend[:user]}'@'localhost'"
    action :create
  end

  # Load initial sql structure
  mariadb_loadsql "/usr/share/icinga2-ido-mysql/schema/mysql.sql" do
    db bend[:db]
  end
end

# Prepare Client configuration
%w( host_groups boxes service_groups ).each { |e| directory "/etc/icinga2/conf.d/custom.d/#{e}" do recursive true end }
custom_d = "/etc/icinga2/conf.d/custom.d"

# Get list of boxes controlled by Icinga and running recipe icinga2::client
search(:node, 'recipes:icinga2\:\:client').each do |box|
  # Look for hostgroup definition. If not found, create hostgroup file 
  if !obj_query(:hostgroup, box[:icinga2][:client][:host_group][:short])

    template "#{custom_d}/host_groups/#{box[:icinga2][:client][:host_group][:short]}.conf" do
      source "HostGroup.conf.erb"
      variables({
        :name => box[:icinga2][:client][:host_group][:short],
        :desc => box[:icinga2][:client][:host_group][:desc]
      })
      mode 0644
      notifies :reload, "service[icinga2]", :delayed
    end

  end if !box[:icinga2][:client][:host_group][:short].nil?

  template "#{custom_d}/boxes/#{box[:fqdn]}.conf" do
    source "HostDefinition.conf.erb"
    variables({
      :box => box
    })
    mode 0644
    notifies :reload, "service[icinga2]", :delayed
    not_if { box[:fqdn].empty? }
  end

end

# Configure users and notifications
template "/etc/icinga2/conf.d/users.conf" do
  source "users.conf.erb"
  variables({
    :users => node[:icinga2][:notification][:users]
  })
  notifies :reload, "service[icinga2]", :delayed
end

# Setup user's group
groups = Array.new(["icingaadmins"])
node[:icinga2][:notification][:users].each_key do |user|
  node[:icinga2][:notification][:users][user][:groups].each { |group| groups << group if !groups.include?(group) }
end
template "/etc/icinga2/conf.d/users-groups.conf" do
  source "users-groups.conf.erb"
  variables({
    :groups => groups
  })
  notifies :reload, "service[icinga2]", :delayed
end

# Clear icinga2 from hosts deleted from Chef's DB
ruby_block ":: Clearing not used boxes..." do
  block do
    Dir.glob("#{custom_d}/boxes/*.conf").each do |file|
      ::FileUtils.rm(file) if search(:node, "fqdn:#{::File.basename(file, '.conf')}").empty?
    end
  end
  notifies :reload, "service[icinga2]", :delayed
end

# Finally, start icinga2 service
service "icinga2" do
  supports :status => true, :restart => true, :reload => true
  action  [ :enable, :start ]
end


