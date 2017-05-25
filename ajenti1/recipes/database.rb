#
# Cookbook Name:: ajenti1
# Recipe:: database
#
# Copyright 2017, Keenan Verbrugge
#
#

mysql -uroot -e "\
  UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root'; \
  DELETE FROM mysql.user WHERE User=''; \
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
  DROP DATABASE IF EXISTS test; \
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; \
  FLUSH PRIVILEGES;"

# Create NextCloud database
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '$MYSQL_NEXTCLOUD_PASSWORD'; CREATE DATABASE nextcloud; GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';"
