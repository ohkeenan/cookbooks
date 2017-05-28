include_recipe "mariadb-enterprise::default"

mysql_backup node['mariadb']['instance'] do
  if (defined?(node['mariadb']['backups_dir']))
    backups_dir node['mariadb']['backups_dir']
  end
  if (defined?(node['mariadb']['root_password']))
    root_password node['mariadb']['root_password']
  end

  action :create
end
