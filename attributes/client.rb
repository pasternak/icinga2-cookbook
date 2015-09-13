# Override this attribute in role/env/node
# if set to nil, it will use default HostGroup for vars.os
#
default[:icinga2][:client][:host_group] = { :short => nil, :desc => nil }

# Default nrpe remote checks. DO NOT EDIT! OVERRIDE node[:icinga2][:client][:nrpe][:custom] instead!
# 
default[:icinga2][:client][:nrpe][:default] = {
                                                "check_disk"  =>  "/usr/lib64/nagios/plugins/check_disk -w 20% -c 10%",
                                                "check_load"  =>  "/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20",
                                                "check_users" =>  "/usr/lib64/nagios/plugins/check_users -w 5 -c 10",
                                                "check_zombie_procs" => "/usr/lib64/nagios/plugins/check_procs -w 5 -c 10 -s Z",
                                                "check_total_procs"  => "/usr/lib64/nagios/plugins/check_procs -w 150 -c 200"
}
# User defined checks (Override this attribute in role/env/node to modify/extend default checks
#
default[:icinga2][:client][:nrpe][:custom] = {}

# Default remote checks (outside nrpe scope)
#
default[:icinga2][:client][:remote][:default] = %w( ssh ping4 ping6 )

# Default icinga server
# Used for allowed_hosts. Others server will be built out from 'node search' query
default[:icinga2][:client][:allowed_hosts] = %w()

# Allow remote command's arguments
default[:icinga2][:client][:dont_blame_nrpe] = 1
