# a. Install Zabbix repository
wget https://repo.zabbix.com/zabbix/4.1/debian/pool/main/z/zabbix-release/zabbix-release_4.1-1+stretch_all.deb
dpkg -i zabbix-release_4.1-1+stretch_all.deb
apt update

# b. Install Zabbix server, frontend, agent
apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-agent

# c. Create initial database 
# mysql -uroot -p
# password
mysql --user="root" --password="password" --execute="create database zabbix character set utf8 collate utf8_bin;"
mysql --user="root" --password="password" --execute="grant all privileges on zabbix.* to zabbix@localhost identified by 'password';"

# Import initial schema and data. You will be prompted to enter your newly created password.
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u zabbix --password="password" zabbix

# d. Configure the database for Zabbix server
# Edit file /etc/zabbix/zabbix_server.conf

sed -i 's/# DBPassword=/DBPassword=password/g' /etc/zabbix/zabbix_server.conf

# e. Configure PHP for Zabbix frontend
# Edit file /etc/zabbix/apache.conf, uncomment and set the right timezone for you.
sed -i 's/# php_value date.timezone.*$/php_value date.timezone America\/Boise/g' /etc/zabbix/apache.conf

# f. Start Zabbix server and agent processes
# Start Zabbix server and agent processes and make it start at system boot:

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo "
If all went well, Zabbix is now installed and running. To access the web GUI, navigate to http://localhost/zabbix."
echo 'The default mysql password for the user "root" has been set to "password". To change this (which you should), run

     mysqladmin --user=root password "newpassword"
'
echo 'The default credentials for the web GUI are:
Admin/zabbix
guest/[empty]'
