include_recipe "mariadb-enterprise::repos"

# Turn off SElinux
if node[:platform] == "centos" and node["platform_version"].to_f >= 6.0 
  execute "Turn off SElinux" do
    command "setenforce 0"
  end
  cookbook_file 'selinux.config' do
    path "/etc/selinux/config"
    action :create
  end
end  # Turn off SElinux

# Install packages
case node[:platform_family]
when "suse"
  execute "install" do
    command "zypper --non-interactive --no-gpg-checks --quiet --gpg-auto-import-keys -n install --from mariadb-enterprise-main MariaDB-server MariaDB-client &> /vagrant/log"
  end
when "debian"
  package 'mariadb-server'
  package 'mariadb-client'
  service "mysql" do
    action :stop
  end 
when "windows"
  windows_package "MariaDB" do
    source "#{Chef::Config[:file_cache_path]}/mariadb.msi"
    installer_type :msi
    action :install
  end
else
  package 'MariaDB-server'
  package 'MariaDB-client'
end

include_recipe "mariadb-enterprise::start"
