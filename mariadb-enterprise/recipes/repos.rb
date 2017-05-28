include_recipe "mariadb-enterprise::default"

if (node['mariadb']['token'] == "")
  msg = "Enterprise token isn't specified!"
  print msg
  raise msg
end

repo = "https://downloads.mariadb.com/enterprise/#{node['mariadb']['token']}/"
case node[:platform_family]
when "debian"
  execute "Downloading package...." do
    command "wget  #{repo}/generate/#{node['mariadb']['version']}/mariadb-enterprise-repository.deb -O /tmp/mariadb-enterprise-repository.deb"
  end
  package 'mariadb-enterprise-repository' do
    source "/tmp/mariadb-enterprise-repository.deb"
    provider Chef::Provider::Package::Dpkg
    action :install
  end
  execute "Updating..." do
    command "apt-get update"
  end
when "rhel", "fedora"
  execute "Downloading package...." do
    command "wget  #{repo}/generate/#{node['mariadb']['version']}/mariadb-enterprise-repository.rpm -O /tmp/mariadb-enterprise-repository.rpm"
  end
  package 'mariadb-enterprise-repository' do
    source "/tmp/mariadb-enterprise-repository.rpm"
    provider Chef::Provider::Package::Rpm
    action :install
  end
when "suse"
  execute "Downloading package...." do
    command "wget  #{repo}/generate/#{node['mariadb']['version']}/mariadb-enterprise-repository-suse.rpm -O /tmp/mariadb-enterprise-repository.rpm"
  end
  package 'mariadb-enterprise-repository' do
    source "/tmp/mariadb-enterprise-repository.rpm"
    provider Chef::Provider::Package::Rpm
    action :install
  end
when "windows"
  arch = node[:kernel][:machine] == "x86_64" ? "winx64" : "win32"
  md5sums_file = "#{Chef::Config[:file_cache_path]}/md5sums.txt"
  remote_file "#{md5sums_file}" do
    source repo + "mariadb-enterprise/" + node['mariadb']['version'] + "/" + arch + "-packages/md5sums.txt"
  end

  file_name = "mariadb-enterprise-" + node['mariadb']['version'] + "-" + arch + ".msi"

  if File.exists?("#{md5sums_file}")
    f = File.open("#{md5sums_file}")
    f.each {|line|
      match = line.split(" ")
      if match[1].end_with?("msi")
        file_name = match[1]
        break
      end
    }
    f.close
  end

  remote_file "#{Chef::Config[:file_cache_path]}/mariadb.msi" do
    source repo + node['mariadb']['version'] + "/" + arch + "-packages/" + file_name
  end
end
