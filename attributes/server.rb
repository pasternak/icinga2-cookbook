default[:icinga2][:backend][:type]  = :mysql

default[:icinga2][:backend][:mysql][:db]  = "icinga"
default[:icinga2][:backend][:mysql][:user]  = "icinga"
default[:icinga2][:backend][:mysql][:password] = "icinga"


# Notifications: user and group definitions
#
default[:icinga2][:notification][:groups] = ["icingaadmins"]

default[:icinga2][:notification][:users] = {
                                            # Override this attribute in role/env
                                            #"icingaadmin" => { :mail => "icinga@localhost", :display => "Icinga 2 Default Admin", :groups => ["icingaadmins"] }
}

