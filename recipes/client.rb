%w( nagios-plugins-nrpe nrpe nagios-plugins-all ).each { |e| package e }

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  variables({
    :icinga_server => (search(:node, 'recipes:icinga2\:\:server').map! { |e| "#{e[:ipaddress]}" }.concat(node[:icinga2][:client][:allowed_hosts])).uniq.join(","),
    :dont_blame_nrpe => node[:icinga2][:client][:dont_blame_nrpe]
  })
  notifies :restart, "service[nrpe]", :delayed
end

node[:icinga2][:client][:nrpe][:default].each do |name, command|
  file "/etc/nrpe.d/#{name}.cfg" do
    content "command[#{name}]=#{command}"
    notifies :restart, "service[nrpe]", :delayed
  end
end

service "nrpe" do
  action [ :enable, :start ]
end
