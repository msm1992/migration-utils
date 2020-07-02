#!/bin/bash

MIGRATION_CLIENT_SOURCE="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/utils/migration-client/org.wso2.carbon.apimgt.migrate.client-3.0.x-2.jar"
APIM_320_HOME="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2am-3.2.0-SNAPSHOT"
PATH_TO_DROPINS="/repository/components/dropins"

copy_migration_client() {
	cp $MIGRATION_CLIENT_SOURCE "$APIM_320_HOME$PATH_TO_DROPINS"
	echo "Migration Client was copied to dropins successfully..."
}

copy_migration_client
