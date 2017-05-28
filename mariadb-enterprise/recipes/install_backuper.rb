include_recipe "mariadb-enterprise::default"

include_recipe "mariadb-enterprise::repos"

case node[:platform]
  when  "centos"
    if node["platform_version"].to_f < 6.0 
      execute "install" do
        command "yum install -yx mysql percona-xtrabackup"
      end
    else
      package 'percona-xtrabackup'
    end
  when "suse", "opensuse", "redhat", "fedora", "debian", "ubuntu"
    package 'percona-xtrabackup'
end

