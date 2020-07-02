drop database if exists apim_db;
drop database if exists shared_db;

create database apim_db;
use apim_db;
source /home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/utils/dbscripts/apimgt/mysql.sql;

create database shared_db;
use shared_db;
source /home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/utils/dbscripts/mysql.sql;
