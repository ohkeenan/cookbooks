include_recipe "mariadb-enterprise::default"

mysql_service node['mariadb']['instance'] do
  if (defined?(node['mariadb']['initial_root_password']))
    initial_root_password node['mariadb']['initial_root_password']
  end
  if (defined?(node['mariadb']['bind_address']))
    bind_address node['mariadb']['bind_address']
  end
  if (defined?(node['mariadb']['port']))
    port node['mariadb']['port']
  end
  if (defined?(node['mariadb']['socket']))
    socket node['mariadb']['socket']
  end
  if (defined?(node['mariadb']['data_dir']))
    data_dir node['mariadb']['data_dir']
  end
  action [:create, :start]
end
