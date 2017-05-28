require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlBackup < Chef::Provider::LWRPBase
      include MysqlCookbook::Helpers

      action :create do

        directory "#{new_resource.backups_dir}" do
            owner 'root'
            group 'root'
            mode '0755'
            recursive true
            action :create
        end
        execute "Create backup" do
          user "root"
          command "innobackupex --user=root --password=#{new_resource.root_password} --defaults-file=#{defaults_file} #{new_resource.backups_dir}"
        end
        execute "Apply log" do
          user "root"
          command "innobackupex --user=root --password=#{new_resource.root_password} --defaults-file=#{defaults_file} --apply-log #{new_resource.backups_dir}/$(ls #{new_resource.backups_dir}/ | sort -r | head -1)"
        end

      end

      action :restore do
        require 'fileutils'
        FileUtils.mv parsed_data_dir, "#{parsed_data_dir}.backup"

        last_backup = "#{new_resource.backups_dir}/$(ls #{new_resource.backups_dir}/ | sort -r | head -1)"
        if (new_resource.restore_source_dir != "")
          last_backup = new_resource.restore_source_dir
        end

        execute "Restore backup" do
          user "root"
          command "innobackupex --user=root --password=#{new_resource.root_password} --defaults-file=#{defaults_file} --copy-back #{last_backup}"
        end
        execute "chown" do
          user "root"
          command "chown mysql:mysql -R #{parsed_data_dir}"
        end
        execute "chcon" do
          user "root"
          command "#{change_context}"
          not_if { change_context == "" }
        end
      end
    end
  end
end
