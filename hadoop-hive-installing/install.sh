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

# download Hive 0.11.0 from official site
if [ ! -f /home/vagrant/hive-0.11.0.tar.gz ]; then
	echo "Start download Hive 0.11.0..."
	wget -c http://mirrors.digipower.vn/apache/hive/stable/hive-0.11.0.tar.gz /home/vagrant/hive-0.11.0.tar.gz

	# untar the package
	tar -xvf /home/vagrant/hive-0.11.0.tar.gz
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

echo "START DOWNLOADING JAVA..."
sudo apt-get install --force-yes --yes openjdk-6-jdk


echo "START INSTALLING MYSQL..."
sudo echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections
sudo echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections
sudo apt-get install --force-yes --yes mysql-server
sudo apt-get install --force-yes --yes mysql-client-core-5.5

echo "Exporting envirionment variable..."
# for first time
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64
export HADOOP_HOME=/home/vagrant/hadoop-1.2.1
export HIVE_HOME=/home/vagrant/hive-0.11.0
export SQOOP_HOME=/home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0
export PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin

# for later
echo 'export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64' >> /home/vagrant/.bashrc 

# set HADOOP_HOME
echo 'export HADOOP_HOME=/home/vagrant/hadoop-1.2.1' >> /home/vagrant/.bashrc 

# set HIVE_HOME
echo 'export HIVE_HOME=/home/vagrant/hive-0.11.0' >> /home/vagrant/.bashrc 

# set SQOOP_HOME
echo 'export SQOOP_HOME=/home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0' >> /home/vagrant/.bashrc 

# export PATH
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin' >> /home/vagrant/.bashrc 


# copy some config file for hadoop.
cp -rf /home/vagrant/hadoop-hive-installing/hadoop/* $HADOOP_HOME/conf/

# exporting java home for hadoop.
echo 'export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64' >> $HADOOP_HOME/conf/hadoop-env.sh

# avoid waning Warning: $HADOOP_HOME is deprecated.
echo 'export HADOOP_HOME_WARN_SUPPRESS="TRUE"' >> $HADOOP_HOME/conf/hadoop-env.sh

# Download JDBC driver jar and store to sqood lib.
wget -c https://mapmap.googlecode.com/files/mysql-connector-java-5.0.8-bin.jar
sudo cp -rf /home/vagrant/mysql-connector-java-5.0.8-bin.jar /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0/lib/mysql-connector-java-5.0.8-bin.jar

# set full permission for hadoop home
sudo chmod -R 777 /home/vagrant/hadoop-1.2.1/

echo "Everything is done, now please ssh to VM and type 'hive' for using hive.\nGood luck!!!"
