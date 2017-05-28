include_recipe "mariadb-enterprise::default"

package 'percona-xtrabackup' do
  action :remove
end

include_recipe "mariadb-enterprise::repos_off"
