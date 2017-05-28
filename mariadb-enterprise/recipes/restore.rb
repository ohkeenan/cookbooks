include_recipe "mariadb-enterprise::default"

include_recipe "mariadb-enterprise::stop"

mysql_backup node['mariadb']['instance'] do
  if (defined?(node['mariadb']['restore_source_dir']))
    restore_source_dir node['mariadb']['restore_source_dir']
  end
  if (defined?(node['mariadb']['backups_dir']))
    backups_dir node['mariadb']['backups_dir']
  end
  if (defined?(node['mariadb']['root_password']))
    root_password node['mariadb']['root_password']
  end

  action :restore
end

include_recipe "mariadb-enterprise::start"

