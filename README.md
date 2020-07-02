# migration-utils
----------------CREATE DATABASES--------------
source /home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/utils/create_db_mysql.sql

----------------CONFIGURE APIM 3.1.0------------------


---------------ADD TENANTS AND USERS(THIS PART IS NOT AUTOMATED YET)----------------------
tenant1 : test.com
	users: admin, publisher, subscriber, creator


----------------MIGRATE DBs-----------------
source /home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/utils/migration-scripts/migration-3.1.0_to_3.2.0/mysql.sql


TEST CUSTOM AUTH HEADER
curl -X GET "https://localhost:8243/customauth/1.0.0" -H "accept: */*" -H "Authorization: Bearer cd5a82c3-ddb1-397c-a69e-6440d1a1cb52" -H "custom:sachini"

