action :create do
  execute "Enable Icinga2 feature #{ new_resource.name }" do
    command "icinga2 feature enable #{ new_resource.name }"
  end
  new_resource.updated_by_last_action(true)
end

action :delete do
  execute "Disable Icinga2 feature #{ new_resource.name }" do
    command "icinga2 feature disable #{ new_resource.name }"
  end
  new_resource.updated_by_last_action(true)
end
