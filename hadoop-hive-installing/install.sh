#! /bin/sh

cd /home/vagrant/

# Download Hadoop
if [ ! -f /home/vagrant/hadoop-1.2.1.tar.gz ]; then
    echo "Downloading Hadoop 1.2.1..."
    wget -qc http://mirror.cogentco.com/pub/apache/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz /home/vagrant/hadoop-1.2.1.tar.gz
    tar -xf /home/vagrant/hadoop-1.2.1.tar.gz
fi

# Download Hive
hive_version=apache-hive-1.0.0-bin
hive_tarball=$hive_version.tar.gz
hive_home=/home/vagrant/$hive_version
if [ ! -d $hive_home ]; then
  mkdir -p $hive_home && cd $hive_home
  echo "Downloading Hive $hive_version..."
  wget -qc http://mirror.cogentco.com/pub/apache/hive/hive-1.0.0/apache-hive-1.0.0-bin.tar.gz $hive_tarball
  tar -x --strip-components=1 -f $hive_tarball
  cd /home/vagrant
fi

# Download Sqoop
if [ ! -f /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz ] ; then
  echo "Downloading Sqoop 1.4.4..."
  wget -qc http://archive.apache.org/dist/sqoop/1.4.4/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz
  tar -xf /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0.tar.gz
fi

echo "Installing Java and Elasticsearch..."
apt-get update -qq
apt-get install -qy curl python-software-properties
add-apt-repository ppa:webupd8team/java
wget -q - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" >> /etc/apt/sources.list

apt-get update -qq

echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -qqy oracle-java8-installer

apt-get install -qqy --force-yes elasticsearch
update-rc.d elasticsearch defaults 95 10

cat > /etc/elasticsearch/elasticsearch.yml <<EOF
cluster.name: elasticsearch
network.host: 0.0.0.0
discovery.zen.minimum_master_nodes: 1
EOF

service elasticsearch restart

echo "Installing MySQL..."
echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections
apt-get install -qq --force-yes --yes mysql-server mysql-client-core-5.5

echo "Exporting environment variables..."
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
echo "export HIVE_HOME=$HIVE_HOME" >> /home/vagrant/.bashrc

# set SQOOP_HOME
echo 'export SQOOP_HOME=/home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0' >> /home/vagrant/.bashrc 

# export PATH
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin' >> /home/vagrant/.bashrc 

# copy some config file for hadoop.
cp -rf /vagrant/hadoop-hive-installing/hadoop/* $HADOOP_HOME/conf/

# exporting java home for hadoop.
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> $HADOOP_HOME/conf/hadoop-env.sh

# avoid waning Warning: $HADOOP_HOME is deprecated.
echo 'export HADOOP_HOME_WARN_SUPPRESS="TRUE"' >> $HADOOP_HOME/conf/hadoop-env.sh

# Download JDBC driver jar and store to sqood lib.
wget -c https://mapmap.googlecode.com/files/mysql-connector-java-5.0.8-bin.jar
sudo cp -rf /home/vagrant/mysql-connector-java-5.0.8-bin.jar /home/vagrant/sqoop-1.4.4.bin__hadoop-1.0.0/lib/mysql-connector-java-5.0.8-bin.jar

# set full permission for hadoop home
sudo chmod -R 777 /home/vagrant/hadoop-1.2.1/

