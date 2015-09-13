# icinga2-enable/disable-feature
actions :create,  :delete
default_action  :create

attribute :name,  :name_attribute =>  true,
                  :kind_of  =>  String,
                  :required =>  true

attr_accessor :exists
