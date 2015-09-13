yum_repository "icinga-stable-release" do
  description "ICINGA (stable release for epel)"
  baseurl "http://packages.icinga.org/epel/$releasever/release/"
  gpgkey  "http://packages.icinga.org/icinga.key"
  action  :create
end

%w( epel-release nagios-plugins-all nagios-plugins-nrpe ).each { |e| package e }
