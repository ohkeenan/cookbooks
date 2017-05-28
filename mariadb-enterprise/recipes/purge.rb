include_recipe "mariadb-enterprise::uninstall"

execute "Configuration cleaning" do
  command "rm -fr /etc/mysql-#{node['mariadb']['instance']}"
end
execute "Data removing" do
  command "rm -fr /usr/share/mysql/ /usr/lib/mysql/ /usr/lib64/mysql/ /var/lib/mysql-#{node['mariadb']['instance']}"
end
