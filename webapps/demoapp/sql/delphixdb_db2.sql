
Getting currently active schema
Syntax:

db2 get schema  
Example: [To get current database schema]

db2 get schema   
Setting another schema to current environment
Syntax:

db2 set schema=<schema_name>  
Example: [To arrange ‘schema1’ to current instance environment]

db2 set schema=schema1 
Creating a new Schema
Syntax: [To create a new schema with authorized user id]

db2 create schema <schema_name> authroization <inst_user> 
Example: [To create “schema1” schema authorized with ‘db2inst2”]

db2 create schema schema1 authorization db2inst2 


db2 create schema delphixdb authorization db2inst1
db2 set schema=delphixdb


[db2inst1@linuxdb2tgt ~]$ db2 "CREATE TABLE TDEPT
>      (DEPTNO   CHAR(3)     NOT NULL,
>       DEPTNAME VARCHAR(36) NOT NULL,
>       MGRNO    CHAR(6),
>       ADMRDEPT CHAR(3)     NOT NULL,
>       PRIMARY KEY(DEPTNO))
>    IN USERSPACE1"
DB20000I  The SQL command completed successfully.

--------------------------------------------------------
--  DDL for Table EMPLOYEES
--------------------------------------------------------

db2 "CREATE TABLE DELPHIXDB.EMPLOYEES 
(EMPLOYEE_ID INTEGER NOT NULL,
FIRST_NAME VARCHAR(50), 
LAST_NAME VARCHAR(50), 
DEPT_NAME VARCHAR(50), 
CITY VARCHAR(50),
PRIMARY KEY(EMPLOYEE_ID)) 
in USERSPACE1
"

db2 list tables for schema delphixdb


--------------------------------------------------------
--  DDL for Table MEDICAL_RECORDS
--------------------------------------------------------

db2 "CREATE TABLE DELPHIXDB.MEDICAL_RECORDS
(PATIENT_ID INTEGER, 
PHONE_NUMBER VARCHAR(30), 
MEDICAL_RECORD_NUMBER VARCHAR(30), 
EMAIL VARCHAR(40), 
ADDRESS VARCHAR(60)) 
in USERSPACE1
"
--------------------------------------------------------
--  DDL for Table PATIENT
--------------------------------------------------------

db2 "CREATE TABLE DELPHIXDB.PATIENT 
(PATIENT_ID INTEGER, 
FIRSTNAME VARCHAR(40), 
LASTNAME VARCHAR(40), 
SOCIAL_SECURITY_NUMBER VARCHAR(11), 
ADDRESS VARCHAR(60), 
CITY VARCHAR(15), 
ZIPCODE VARCHAR(10), 
DOB DATE, 
PHONE_NUMBER VARCHAR(24), 
EMAIL VARCHAR(40)) 
in USERSPACE1
"

--------------------------------------------------------
--  DDL for Table PATIENT_DETAILS
--------------------------------------------------------

db2 "CREATE TABLE DELPHIXDB.PATIENT_DETAILS 
(PATIENT_ID INTEGER, 
PHONE_NUMBER VARCHAR(30), 
MEDICAL_RECORD_NUMBER VARCHAR(30), 
ACCOUNT_NUMBER VARCHAR(30), 
CC_NUMBER VARCHAR(30)) 
in USERSPACE1
"


REM INSERTING into DELPHIXDB.EMPLOYEES
-- delete from employees;	

db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (1,'Woody','Evans','Solution Architects','Hoboken')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (2,'Jeff','Zeisler','Solution Architects','Menlo Park')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (3,'Dr. Jeff','Wootton','Lyrical Rap Studies','Reston')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (4,'Dino','Konstantinos','Sales','Fantasyland')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (5,'Ted','Girard','Sales','Bethesda')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (6,'Adam','Bowen','No Sleep Till','Brooklyn')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (7,'Adam','Bowen','Solution Architects','Ashland')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (8,'Luther','Vandross','Superstar','NYC')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (9,'Ted','Girard','Sales','Bethesda')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (10,'Jude','Seth','Solution Architects','DK')"
db2 "Insert into DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) values (11,'Darth','Vader','Imperial Army','Death Star')"

REM INSERTING into DELPHIXDB.MEDICAL_RECORDS
db2 "Insert into DELPHIXDB.MEDICAL_RECORDS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,EMAIL,ADDRESS) values (1,'803-345-6789','4483838','raygun@aol.com','40 Presidential Dr')"
db2 "Insert into DELPHIXDB.MEDICAL_RECORDS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,EMAIL,ADDRESS) values (2,'415-345-6789','5483838','bush@aol.com','2943 SMU Blvd')"
db2 "Insert into DELPHIXDB.MEDICAL_RECORDS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,EMAIL,ADDRESS) values (3,'650-456-0987','6483838','obama@aol.com','1600 Pennsylvania Ave')"
db2 "Insert into DELPHIXDB.MEDICAL_RECORDS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,EMAIL,ADDRESS) values (4,'123-321-9990','7483838','abe@hotmail.com','112 N 6th St')"
db2 "Insert into DELPHIXDB.MEDICAL_RECORDS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,EMAIL,ADDRESS) values (5,'440-345-2345','8483838','Jeff@whitehouse.gov','7415 Arlington Blvd')"

REM INSERTING into DELPHIXDB.PATIENT
db2 "Insert into DELPHIXDB.PATIENT (PATIENT_ID,FIRSTNAME,LASTNAME,SOCIAL_SECURITY_NUMBER,ADDRESS,CITY,ZIPCODE,DOB,PHONE_NUMBER,EMAIL) values (1,'Ronald','Reagan','474-78-1234','40 Presidential Dr','Simi Valley','93065-0987',null,'803-345-6789','raygun@aol.com')"
db2 "Insert into DELPHIXDB.PATIENT (PATIENT_ID,FIRSTNAME,LASTNAME,SOCIAL_SECURITY_NUMBER,ADDRESS,CITY,ZIPCODE,DOB,PHONE_NUMBER,EMAIL) values (2,'George','Bush','111-67-4321','2943 SMU Blvd','Dallas','75205-7367',null,'415-345-6789','bush@aol.com')"
db2 "Insert into DELPHIXDB.PATIENT (PATIENT_ID,FIRSTNAME,LASTNAME,SOCIAL_SECURITY_NUMBER,ADDRESS,CITY,ZIPCODE,DOB,PHONE_NUMBER,EMAIL) values (3,'Barack','Obama','650-12-5432','1600 Pennsylvania Ave','Washington DC','20500-6353',null,'650-456-0987','obama@aol.com')"
db2 "Insert into DELPHIXDB.PATIENT (PATIENT_ID,FIRSTNAME,LASTNAME,SOCIAL_SECURITY_NUMBER,ADDRESS,CITY,ZIPCODE,DOB,PHONE_NUMBER,EMAIL) values (4,'Abraham','Lincoln','673-11-3479','112 N 6th St','Springfield','62701-6363',null,'123-321-9990','abe@hotmail.com')"
db2 "Insert into DELPHIXDB.PATIENT (PATIENT_ID,FIRSTNAME,LASTNAME,SOCIAL_SECURITY_NUMBER,ADDRESS,CITY,ZIPCODE,DOB,PHONE_NUMBER,EMAIL) values (5,'Thomas','Jefferson','123-68-8765','7415 Arlington Blvd','Falls Church','22042-4242',null,'440-345-2345','Jeff@whitehouse.gov')"

REM INSERTING into DELPHIXDB.PATIENT_DETAILS
db2 "Insert into DELPHIXDB.PATIENT_DETAILS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,ACCOUNT_NUMBER,CC_NUMBER) values (1,'803-345-6789','3338383','4483838','4283897623459088')"
db2 "Insert into DELPHIXDB.PATIENT_DETAILS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,ACCOUNT_NUMBER,CC_NUMBER) values (2,'415-345-6789','7338383','5483838','5683897623459088')"
db2 "Insert into DELPHIXDB.PATIENT_DETAILS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,ACCOUNT_NUMBER,CC_NUMBER) values (3,'650-456-0987','8338383','6483838','3783897623459088')"
db2 "Insert into DELPHIXDB.PATIENT_DETAILS (PATIENT_ID,PHONE_NUMBER,MEDICAL_RECORD_NUMBER,ACCOUNT_NUMBER,CC_NUMBER) values (4,'123-321-9990','2338383','7483838','4283897623459088')"

