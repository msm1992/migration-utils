#!/bin/bash
source ./config_changes.sh

MIGRATION_CLIENT_SOURCE="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/migration-utils/wso2-api-migration-client/org.wso2.carbon.apimgt.migrate.client-3.0.x-3.jar"
MIGRATION_RESOURCES="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/migration-utils/wso2-api-migration-client/migration-resources"
TENANT_LOADER_JAR="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/migration-utils/resources/tenantloader-1.0.jar"
APIM_320_HOME="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2am-3.2.0-SNAPSHOT"
APIM_310_HOME="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2am-3.1.0"
PATH_TO_DROPINS="/repository/components/dropins"
PATH_TO_SYNAPSE_CONFIGS="/repository/deployment/server/synapse-configs/default"
PATH_TO_TENANTS_FOLDER="/repository/tenants"
PATH_TO_EXECUTION_PLANS="/repository/deployment/server/executionplans"
PATH_TO_DEPLOYMENT_TOML="/repository/conf/deployment.toml"

copy_migration_client() {
	cp $MIGRATION_CLIENT_SOURCE "$APIM_320_HOME$PATH_TO_DROPINS"
	echo "Migration Client was copied to dropins successfully..."
}

remove_migration_client() {
	rm "$APIM_320_HOME$PATH_TO_DROPINS/org.wso2.carbon.apimgt.migrate.client-3.0.x-3.jar"
	echo "Migration Client was removed from dropins successfully..."
}

copy_synapse_configs() {
	##SUPER TENANT
	rm -r "$APIM_320_HOME$PATH_TO_SYNAPSE_CONFIGS"
	cp -r "$APIM_310_HOME$PATH_TO_SYNAPSE_CONFIGS" "$APIM_320_HOME$PATH_TO_SYNAPSE_CONFIGS"
	echo "Synapse-configs for super tenant were copied successfully..."

	##TENANTS
	cp -r "$APIM_310_HOME$PATH_TO_TENANTS_FOLDER" "$APIM_320_HOME$PATH_TO_TENANTS_FOLDER"
	echo "Synapse-configs for tenants were copied successfully..."
}

copy_execution_palns() {
	rm -r "$APIM_320_HOME$PATH_TO_EXECUTION_PLANS"
	cp -r "$APIM_310_HOME$PATH_TO_EXECUTION_PLANS" "$APIM_320_HOME$PATH_TO_EXECUTION_PLANS"
	echo "Execution plans were copied successfully..."
}

copy_tenant_loader_jar() {
	cp $TENANT_LOADER_JAR "$APIM_320_HOME$PATH_TO_DROPINS"
	echo "Migration Client was copied to dropins successfully..."
}

add_reindexing_config() {
	echo "[indexing]\nre_indexing = 1" >> "$APIM_320_HOME$PATH_TO_DEPLOYMENT_TOML"
	echo "Re-indexing config added to deployment.toml successfully..."
}


setup_320
copy_synapse_configs
copy_execution_palns
echo "Please run DB migration scripts against APIM_DB and confirm to continue (y/n)"
read isAPIMDBMigrated
if [[ "y" == $isAPIMDBMigrated ]]
then
	copy_migration_client
	echo "Start APIM server @ $APIM_320_HOME with below command to migrate API artifacts..."
	echo "sh wso2server.sh -DmigrateFromVersion=3.1.0"
	echo "Confirm APIM 3.2.0 artifacts migrated(y/n)..."
	read shouldContinue
	if [[ "y" == $shouldContinue ]]
	then
		remove_migration_client
		echo "Please run reg-index.sql against SHARED_DB and confirm(y/n)"
		read ranregindexsql
		if [[ "y" == $ranregindexsql ]]
		then
			copy_tenant_loader_jar	
			add_reindexing_config
			echo "Now start APIM 3.2.0 to finish APIM Migration... Make sure to remove tenant loader jar after the migration..."		
		else
			echo "Cannot continue without executing reg-index.sql... Hence exiting"
		fi
	else
		echo "Cannot continue without migrating API artifacts... Hence exiting"
	fi
else
	echo "Cannot continue without migrating APIM DB... Hence exiting"
fi
