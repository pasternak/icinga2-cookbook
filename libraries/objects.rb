module Icinga2
  module Object
    def obj_query(type, name)
      cmd = %x[icinga2 object list --type #{type.to_s} --name #{name.to_s}]
      #$?.exitstatus == 0 && (cmd =~ /^Object '#{name.to_s}' of type '#{type.to_s}':/i)
      $?.exitstatus == 0 && (cmd =~ /(^Object 'icinga2.box-test' of type 'host':).+(managed_by = "chef")/im)
    end
  end
end
