#!/bin/bash



echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+"
echo "+"
echo "+"
echo "+ [1] ToughRADIUS--sqlite3数据库版本"
echo "+ [2] ToughRADIUS--mysql(mariadb)数据库版本"
echo "+"
echo "+"
echo "+"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "请选择一个安装版本，然后回车！"   "Please select an installation version, and then enter! "
read mirror

if [ "$mirror" = '1' ]; then
	echo "***升级系统*****" 
yum update -y  
echo "*****安装wget********"
yum -y install wget unzip
echo "*****下载ToughRADIUS安装包********"
wget https://github.com/talkincode/ToughRADIUS/archive/release-stable.zip -O /opt/release-stable.zip
echo "*****进入 /opt目录********"
cd /opt
echo "*****解压ToughRADIUS安装包********"
unzip release-stable.zip
echo "****重命名为toughradius*****"
mv ToughRADIUS-release-stable /opt/toughradius
echo "*****进入 /opt/toughradius目录********"
cd /opt/toughradius
echo "*****安装toughradius.....********"
make all
echo "*****初始化数据库********"
make initdb
echo "*****启动toughradius...********"
service toughradius start
echo "*****开启1816端口********"
firewall-cmd --permanent --add-port=1816/tcp
firewall-cmd --permanent --add-port=1812/udp
firewall-cmd --permanent --add-port=1813/udp
firewall-cmd --reload
elif [ "$mirror" = '2' ]; then
	echo "***升级系统*****" 
yum update -y  
echo "******安装mariadb数据库*************"
yum install -y mariadb mariadb-server mariadb-devel MySQL-python
echo "******启动mariadb数据库*************"
systemctl start mariadb.service 
echo "******设置开机启动mariadb数据库*************"
systemctl enable mariadb.service
echo "******拷贝my-huge.cnf 到/etc/my.cnf*************"
cp /usr/share/mysql/my-huge.cnf /etc/my.cnf
echo "*****修改root用户密码 并创建toughradius********"
mysql -e "use mysql;
UPDATE user SET Password = PASSWORD('guofeng') WHERE user = 'root';
FLUSH PRIVILEGES;
create database toughradius DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
quit"
echo "******重新启动mariadb数据库*************"
systemctl restart mariadb.service
echo "*****安装wget********"
yum -y install wget unzip
echo "*****下载ToughRADIUS安装包********"
wget https://github.com/talkincode/ToughRADIUS/archive/release-stable.zip -O /opt/release-stable.zip
echo "*****进入 /opt目录********"
cd /opt
echo "*****解压ToughRADIUS安装包********"
unzip release-stable.zip
echo "****重命名为toughradius*****"
mv ToughRADIUS-release-stable /opt/toughradius
echo "*****进入 /opt/toughradius目录********"
cd /opt/toughradius
echo "*****安装toughradius.....********"
make all

echo "*******修改数据库配置文件************"
echo "
{
    \"admin\": {
        \"host\": \"0.0.0.0\", 
        \"port\": 1816
    }, 
    \"conf_file\": \"etc/toughradius.json\", 
    \"database\": {
        \"backup_path\": \"/var/toughradius/data\",
    	\"dbtype\": \"mysql\",
    	\"dburl\": \"mysql://root:guofeng@127.0.0.1:3306/toughradius?charset=utf8\",
    	\"echo\": 0,
    	\"pool_recycle\": 300,
    	\"pool_size\": 60
    }, 
    \"radiusd\": {
        \"acct_port\": 1813, 
        \"auth_port\": 1812, 
        \"host\": \"0.0.0.0\"
    }, 
    \"redis\": {
        \"host\": \"127.0.0.1\", 
        \"passwd\": \"\", 
        \"port\": 16370
    }, 
    \"syslog\": {
        \"enable\": 0, 
        \"level\": \"INFO\", 
        \"port\": 514, 
        \"server\": \"127.0.0.1\", 
        \"shost\": \"toughradius_admin\"
    }, 
    \"system\": {
        \"debug\": 1, 
        \"license\": \"free license\", 
        \"secret\": \"CRTCcMB7tfnXU8aXIyfavfuqruvXkNng\", 
       \"service_url\": \"http://service.toughstruct.net:9079\", 
        \"tz\": \"CST-8\"
    }
}

" > /etc/toughradius.json
echo "*****初始化数据库********"
make initdb
echo "*****启动toughradius...********"
service toughradius start
echo "*****开启1816-1812-1813端口********"
firewall-cmd --permanent --add-port=1816/tcp
firewall-cmd --permanent --add-port=1812/udp
firewall-cmd --permanent --add-port=1813/udp
firewall-cmd --reload

fi


echo "*****开始你ToughRADIUS旅程吧--访问地址-----http:ip:1816------********"
echo "*****注：安装脚本中的mariadb  数据库密码是 guofeng  有需要的请自行修改 发扬互助精神 方便他人  QQ：13366669903 ------********"