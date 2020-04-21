
The application directory "demoapp" contains the Java Server Pages (JSP) 
for sample Employees and Medical Application for MS SQL Server, Oracle, 
Sybase, DB, PostgreSQL, MySQL and Mongo Databases. 

Also included are simple Virtualization and Masking API applications to 
demonstrate the power of Delphix API's.    

-----------------------------------------------------------------------
-- Installation  Notes --
-------------------------

This bundle include the complete Tomcat Application, including all the 
necessary jar (jdbc) files and Delphix Demo Application

1.)  Unzip the Tomcat tar or zip bundle in a folder that DOES NOT have a "tomcat" sub-directory.

# verify files

2.)  Start / Stop Tomcat Application. Current configuration uses port 8081
     netstat -an | grep 8081
     if nothing is running on port 8081, start up the tomcat application;
     cd [path_to_tomcat_directory]/bin
 
     # Mac/Linux/Unix 
     ./startup.sh
     ./shutdown.sh

     # Windows 
     startup.bat
     shutdown.bat

2.)  Update / change database connection information
     -- see inforamtion below

3.)  Create database tables/data  if required, see DDL/SQL within the sql directory of the application.
     NOTE:  This application supports both the EMPLOYEE demo databases, with and without
     the EMPLOYEE_ID column/primary key

4.)  Open web browser to 
     http://localhost:8081/demoapp/index.jsp

#
# Start application  directly into Employee/Medical Records Page without HTML header banner ...
#
# Source ...
http://localhost:8081/demoapp/redirect.jsp?sessionid=mysession&dbType=oracle&dataSource=oracle_source&sqlUpper=yes&banner=no
# Target ...
http://localhost:8081/demoapp/redirect.jsp?sessionid=mysession&dbType=oracle&dataSource=oracle_target&sqlUpper=yes&banner=no


-----------------------------------------------------------------------
-- Applications Notes --
------------------------

For ALL applications, verify that the source database has the correct 
protocols enabled and is accessible from "this computer" hosting this
set of applications. 

For API Demos, verify that "this computer" has access to the Delphix Platform;

http://<delphix_engine>:80/
... and/or ...
https://<delphix_engine>:443/


-----------------------------------------------------------------------
--
-- Database Connections ...
--
The database connections are defined in the application META-INF/context.xml file.

For example: 
  C:\path_to_tomcat\webapps\[application_directory]\META-INF\context.xml
  /path_to_tomcat/webapps/[application_directory]/META-INF/context.xml

The application will make changes to this file from the respective web page! 

http://localhost:8081/demoapp/read_xml.jsp



-----------------------------------------------------------------------
--
-- JSP Files ...
--

index.jsp               -> Main Page with Application links to Vendor Databases
redirect.jsp            -> Used to logout, clear session variables and redirect to target page

index_app.jsp 		-> Employee Listing Page 
masking_app.jsp  	-> Medical Records and Patient Page
insertdb_app.jsp        -> Database Insert/Update Records
deletedb_app.jsp	-> Database Delete Records

mongo.jsp               -> Mongo Employee Page
mongodb.jsp             -> Mongo Employee DB Data
mongo_masking.jsp       -> Mongo Medical Records Page
mongodb2.jsp            -> Mongo Medical DB Data

read_xml.jsp		-> Read/Write Database Connections in context.xml file
read_one.jsp		-> Read a context.xml file entry and return the parameters 
                           (used by mongodb[2].jsp and API pages)

selfservice.jsp		-> Virtualization API Demo Application
selfmasking.jsp         -> Masking API Demo Application
self_classes.jsp	-> Java Classes used by the selfservice.jsp page
provision.jsp		-> Provision Parameters 
get_job.jsp		-> Jquery/AJAX Job Update Div Content

platform_config.jsp     -> Configure the Delphix Virtualization and Masking Platforms



-----------------------------------------------------------------------
--
-- Tomcat Database Jar Files 
--

Oracle        ->  ojdbc6.jar
MySQL         ->  mysql-connector-java-5.1.36-bin.jar
Sybase        ->  jtds-1.3.1.jar
PostgreSQL    ->  postgresql-9.4-1201.jdbc41.jar
MS SQL Server ->  sqljdbc42.jar
MongoDB       ->  mongo-java-driver-3.6.3.jar
DB2           ->  db2jcc4.jar

JSON Parsing  ->  json-simple-1.1.jar





-----------------------------------------------------------------------
-- Microsoft SQL Server --
--------------------------

Verify that the source Microsoft SQL Server has TCPIP protocol is enabled, 
no firewall restrictions and source port number, typically 1433


-----------------------------------------------------------------------
-- MySQL --
-----------

The source MySQL Database must support network connections. THE FOLLOWING changes
are REQUIRED to allow network access from the MySQL Database Server.

NOTE: These changes are DONE on the Server running the MySQL Database.



The default my.ini file required changes to allow network connections are:

# Change here for bind listening, use the MySQL server IP address 
# or comment out the bind-address parameter
bind-address="172.16.160.126" 

#skip-networking

Verify MySQL Port in the my.ini file, typically 3306



And the database user must have '%' host access or specific client ip host access.

CREATE USER 'delphixdb'@'%' IDENTIFIED BY 'delphixdb';
GRANT USAGE ON *.* TO 'delphixdb'@'%' IDENTIFIED BY 'delphixdb' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
GRANT ALL PRIVILEGES ON 'delphixdb'.* TO 'delphixdb'@'%';

CREATE USER 'delphixdb'@'localhost' IDENTIFIED BY 'delphixdb';
GRANT USAGE ON *.* TO 'delphixdb'@'localhost' IDENTIFIED BY 'delphixdb' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;

SQL> FLUSH PRIVILEGES;


-----------------------------------------------------------------------
-- PostgreSQL --
----------------

The default pg_hba.conf file required changes to allow network connections.

NOTE: These changes are DONE on the Server running the PostgreSQL Database.

Use the IP address subnet for your client connections.

	
host    all             all             172.16.160.0/24   	trust


-----------------------------------------------------------------------
-- Oracle --
------------

Access to listener port from database,  tnsping [SID] or [SERVICE_NAME]
i.e.  tnsping orcl



*** End of Readme Notes ***

