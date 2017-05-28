require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MysqlBackup < Chef::Resource::LWRPBase
      self.resource_name = :mysql_backup
      actions :create, :restore
      default_action :create

      attribute :instance, kind_of: String, name_attribute: true
      attribute :restore_source_dir, kind_of: String, default: ""
      attribute :backups_dir, kind_of: String, default: "/data/backups/mysql"
      attribute :root_password, kind_of: String, default: "123456"

      attribute :data_dir, kind_of: String, default: nil
      attribute :version, kind_of: String, default: nil
    end
  end
end
