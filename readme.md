## Tournament Database

Steps to create database:
* Install vagrant
* Save the tournament directory inside the vagrant shared directory
* From the vagrant directory, initialize the virtual machine with
```
vagrant up
```
* Access the virtual machine via
```
vagrant ssh
```
* Access the tournament directory via cd /vagrant/tournament
```
cd /vagrant/tournament
```
* Access the psql command line interface via
```
psql
```
* Import tournament.sql to create the database
```
\i tournament.sql
```
* Quit the PSQL interface
```
\q
```
Run tournament.py or the unit testing program tournment_test.py
```
python tournment_test.py
```
####Required Python modules:
* psycopg2
* bleach
