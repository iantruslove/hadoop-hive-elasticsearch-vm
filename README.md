vagrant-hadoop-hive
===================

Create a box which includes
* Oracle Java 8
* Apache Hadoop 1.2.1
* Apache Hive 1.0.0
* Mysql 5.5
* Apache Sqoop 1.4.4
* Elasticsearch 1.4

Use
===

Prerequisites:

* Vagrant
* Vagrant Hostmanager plugin (https://github.com/smdahlen/vagrant-hostmanager)

Clone this project to local machine and run

    vagrant up

This would up the ubuntu server box and install some packages. Once running is done, you should see the "Good luck!" message, so everything shoud be ready. 

* SSH to VM

		vagrant ssh

* Keys for Self-SSH:

```sh
# For starting hadoop without asking the password:
ssh-keygen -t dsa -P '' -f /home/vagrant/.ssh/id_dsa
cat /home/vagrant/.ssh/id_dsa.pub >> /home/vagrant/.ssh/authorized_keys
```

* Prepare for first run:

```sh
# Create hdfs folder
mkdir /home/vagrant/hdfs
chmod -R 777 /home/vagrant/hdfs/

# Format Hadoop HDFS
hadoop namenode -format -force

# Start Hadoop
start-all.sh

# Preparing HDFS for Hive
hadoop fs -mkdir /tmp 
hadoop fs -mkdir /user/hive/warehouse
hadoop fs -mkdir /tmp/hive
hadoop fs -chmod a+rw /tmp/hive
```

* Starting Hive

    	hive
    
* For testing, create a sample table

		hive>CREATE TABLE pokes (foo INT, bar STRING);

* Use Sqoop

		sqoop help

* Use MySql

		mysql -uroot -proot

Access DFS on browser: http://hadoop-hive-elasticsearch:50070/dfshealth.jsp
    
Access job tracker on browser: http://hadoop-hive-elasticsearch:50030/jobtracker.jsp
    

Test import data from mysql to hive
==============================

* Move to /vagrant

		cd /vagrant

* Create mysql database
	
		mysql -uroot -proot create database test_db

* Import sample database to mysql

		mysql test_db -uroot -proot < hedgefund-data.sql
* Create a Hive database called "test_db"
 
		hive> create database test_db;

* Import mysql table to Hive

		sqoop import --verbose --fields-terminated-by ',' --connect jdbc:mysql://localhost/test_db --table filings --username root --password root --hive-import --warehouse-dir /user/hive/warehouse/test_db.db --fields-terminated-by ',' --split-by id --hive-database test_db --hive-table filings

Notes
=====
* filings a sample table.
* dev-hadoop is forwarding to 192.168.33.15 automatic, this is private ip of Virtual machine, you can change in Vagrantfile
* When vagrant up again, you must start hadoop manualy too.
