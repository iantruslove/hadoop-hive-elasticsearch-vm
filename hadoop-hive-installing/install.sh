#! /bin/sh
#
# This script would install openjdk 1.7
# and hadoop 1.2.1
# and hive 0.11.0
# @Date 2014/1/1
# @Author: CongDang
# @Email: congdang@asnet.com.vn

# back to home folder (/home/user_name)
cd /home/vagrant/

# download Hadoop 1.2.1 from official site
if [ ! -f /home/vagrant/hadoop-1.2.1.tar.gz ]; then
    echo "Start download Hadoop 1.2.1 ..."
    wget -c http://mirrors.digipower.vn/apache/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz /home/vagrant/hadoop-1.2.1.tar.gz

	# untar the package.
	tar -xvf /home/vagrant/hadoop-1.2.1.tar.gz
	
fi

# download Hive 1.0.0
hive_version=apache-hive-1.0.0-bin
hive_tarball=$hive_version.tar.gz
hive_home=/home/vagrant/$hive_version
if [ ! -d $hive_home ]; then
  mkdir -p $hive_home && cd ~/$hive_home
  echo "Start download Hive 1.0.0..."
  wget -c http://mirror.cogentco.com/pub/apache/hive/hive-1.0.0/apache-hive-1.0.0-bin.tar.gz $hive_tarball
  tar -xv --strip-components=1 -f $hive_tarball
  cd ~
fi

# download Sqoop 1.4.4 from official site
if [ ! -f /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz ]; then
	echo "Start download sqoop 1.4.4 ..."
	wget -c http://archive.apache.org/dist/sqoop/1.4.4/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz

	# untar the package
	tar -xvf /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz
fi


# installing java and set java home
# install open java 7
echo "UPDATING OS..."
sudo apt-get update

echo "INSTALLING JAVA..."
apt-get install -y curl python-software-properties
add-apt-repository ppa:webupd8team/java
apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
apt-get install -qqy oracle-java8-installer

echo "INSTALLING ELASTICSEARCH..."
wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" >> /etc/apt/sources.list
apt-get update
apt-get install elasticsearch
update-rc.d elasticsearch defaults 95 10

cat > /etc/elasticsearch/elasticsearch.yml <<EOF
cluster.name: elasticsearch
network.host: 0.0.0.0
discovery.zen.minimum_master_nodes: 1
EOF

service elasticsearch restart

echo "START INSTALLING MYSQL..."
sudo echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections
sudo echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections
sudo apt-get install --force-yes --yes mysql-server
sudo apt-get install --force-yes --yes mysql-client-core-5.5

echo "Exporting environment variable..."
# for first time
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export HADOOP_HOME=/home/vagrant/hadoop-1.2.1
export HIVE_HOME=$hive_home
export SQOOP_HOME=/home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0
export PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin

# for later
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /home/vagrant/.bashrc

# set HADOOP_HOME
echo 'export HADOOP_HOME=/home/vagrant/hadoop-1.2.1' >> /home/vagrant/.bashrc

# set HIVE_HOME
echo "export HIVE_HOME=/home/vagrant/$HIVE_HOME" >> /home/vagrant/.bashrc

# set SQOOP_HOME
echo 'export SQOOP_HOME=/home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0' >> /home/vagrant/.bashrc 

# export PATH
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin' >> /home/vagrant/.bashrc 

# copy some config file for hadoop.
cp -rf /home/vagrant/hadoop-hive-installing/hadoop/* $HADOOP_HOME/conf/

# exporting java home for hadoop.
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> $HADOOP_HOME/conf/hadoop-env.sh

# avoid waning Warning: $HADOOP_HOME is deprecated.
echo 'export HADOOP_HOME_WARN_SUPPRESS="TRUE"' >> $HADOOP_HOME/conf/hadoop-env.sh

# Download JDBC driver jar and store to sqood lib.
wget -c https://mapmap.googlecode.com/files/mysql-connector-java-5.0.8-bin.jar
sudo cp -rf /home/vagrant/mysql-connector-java-5.0.8-bin.jar /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0/lib/mysql-connector-java-5.0.8-bin.jar

# set full permission for hadoop home
sudo chmod -R 777 /home/vagrant/hadoop-1.2.1/

