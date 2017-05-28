include_recipe "mariadb-enterprise::default"

mysql_service node['mariadb']['instance'] do
  action [:stop]
end
