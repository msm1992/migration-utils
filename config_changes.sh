#!/bin/bash

IS_KM_510_HOME="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2is-km-5.10.0"
APIM_310_HOME="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2am-3.1.0"
APIM_320_HOME="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2am-3.2.0-SNAPSHOT"
deployment_toml310="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/wso2am-3.1.0/repository/conf/deployment.toml"
PATH_TO_DEPLOYMENT_TOML="/repository/conf/deployment.toml"
PATH_TO_LIB="/repository/components/lib/"

#$1 - DB Type
#$2 - APIM DB (not used atm)
#$3 - Shared DB URL (not used atm)
#$4 - username
#$5 - password
#$6 - path to deployment.toml
update_db_configs() {
	sed -i "s/\"h2\"/\"$1\"/g" $6	#db type
	sed -i 's/"jdbc:h2:.\/repository\/database\/WSO2AM_DB;AUTO_SERVER=TRUE;DB_CLOSE_ON_EXIT=FALSE"/"jdbc:mysql:\/\/localhost:3306\/apim_db"/g' $6
	sed -i 's/"jdbc:h2:.\/repository\/database\/WSO2SHARED_DB;DB_CLOSE_ON_EXIT=FALSE"/"jdbc:mysql:\/\/localhost:3306\/shared_db"/g' $6
	sed -i "21 s/\"wso2carbon\"/\"$4\"/" $6
	sed -i "22 s/\"wso2carbon\"/\"$5\"/" $6
	sed -i "27 s/\"wso2carbon\"/\"$4\"/" $6
	sed -i "28 s/\"wso2carbon\"/\"$5\"/" $6
	
	echo "APIM and Shared DB configs updated..."
}

#$1 DB type
#$2 destination_path
copy_db_connector_to_lib() {
	if [[ "mysql" == $1 ]]
	then
		cp /home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/migration-utils/resources/db_connectors/mysql/mysql-connector-java-5.1.35-bin.jar $2
		echo "Copied mysql connector jar to lib..."
	fi 
}

## CONFIGURE 3.1.0 ENVIRONMENT
setup_310() {
	update_db_configs "mysql" "jdbc:mysql://localhost:3306/apim_db" "jdbc:mysql://localhost:3306/shared_db" "root" "root" "$APIM_310_HOME$PATH_TO_DEPLOYMENT_TOML"

	copy_db_connector_to_lib "mysql" "$APIM_310_HOME$PATH_TO_LIB"
	echo "3.1.0 environement successfuly configured..."
} 
## CONFIGURE 3.2.0 ENVIRONMENT
setup_320() {
	update_db_configs "mysql" "jdbc:mysql://localhost:3306/apim_db" "jdbc:mysql://localhost:3306/shared_db" "root" "root" "$APIM_320_HOME$PATH_TO_DEPLOYMENT_TOML"

	copy_db_connector_to_lib "mysql" "$APIM_320_HOME$PATH_TO_LIB"
	echo "3.2.0 environement successfuly configured..."
}

setup_iskm_510_minimum() {
	IS_KM_DEP_TOML="$IS_KM_510_HOME$PATH_TO_DEPLOYMENT_TOML"
	sed -i '7 a offset = 1' "$IS_KM_DEP_TOML" 
	echo "IS KM Configured at port offset 1..."

	update_db_configs "mysql" "jdbc:mysql://localhost:3306/apim_db" "jdbc:mysql://localhost:3306/shared_db" "root" "root" "$IS_KM_510_HOME$PATH_TO_DEPLOYMENT_TOML"
	copy_db_connector_to_lib "mysql" "$IS_KM_510_HOME$PATH_TO_LIB"

	echo -e "\n[[apim.gateway.environment]]\r\nname = \"Production and Sandbox\"\r\ntype = \"hybrid\"\r\ndescription = \"This is a hybrid gateway that handles both production and sandbox token traffic.\"\r\nservice_url = \"https://localhost:9443/services/\"\r\nusername= \"\${admin.username}\"\r\npassword= \"\${admin.password}\"" >> "$IS_KM_DEP_TOML"

	#todo: add this before apim.throttling.url_group config
	echo -e "\n[apim.throttling]\r\nenable_data_publishing = false\r\nenable_policy_deploy = false\r\nenable_blacklist_condition = false\r\nenable_decision_connection = false" >> "$IS_KM_DEP_TOML"
}

setup_apim_310_with_iskm() {
	update_db_configs "mysql" "jdbc:mysql://localhost:3306/apim_db" "jdbc:mysql://localhost:3306/shared_db" "root" "root" "$APIM_310_HOME$PATH_TO_DEPLOYMENT_TOML"
	copy_db_connector_to_lib "mysql" "$APIM_310_HOME$PATH_TO_LIB"
	echo -e "\n[apim.key_manager]\r\nservice_url = \"https://localhost:9444/services/\"" >> "$APIM_310_HOME$PATH_TO_DEPLOYMENT_TOML"
}

# $1 admin username
# $2 admin password 
# $3 tenant domain
# $4 email
# $5 firstname
# $6 lastname
add_tenant() {
	curl -k -H "Content-Type: application/soap+xml;charset=UTF-8;"  -H "SOAPAction:urn:addTenant" --basic -u "admin:admin" --data "<soapenv:Envelope xmlns:soapenv=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ser=\"http://services.mgt.tenant.carbon.wso2.org\" xmlns:xsd=\"http://beans.common.stratos.carbon.wso2.org/xsd\"><soapenv:Header/><soapenv:Body><ser:addTenant><ser:tenantInfoBean><xsd:admin>$1</xsd:admin><xsd:adminPassword>$2</xsd:adminPassword><xsd:active>true</xsd:active><xsd:tenantDomain>$3</xsd:tenantDomain><xsd:email>$4</xsd:email><xsd:firstname>$5</xsd:firstname><xsd:lastname>$6</xsd:lastname></ser:tenantInfoBean></ser:addTenant></soapenv:Body></soapenv:Envelope>" https://localhost:9443/services/TenantMgtAdminService.TenantMgtAdminServiceHttpsSoap11Endpoint
}

# $1 tenant admin username
# $2 tenant admin password
# $3 username
# $4 password
# $5 rolelist
add_user() {
	curl -k -H "Content-Type: application/soap+xml;charset=UTF-8;"  -H "SOAPAction:urn:addTenant" --basic -u "$1:$2" --data "<soapenv:Envelope xmlns:soapenv=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsd=\"http://org.apache.axis2/xsd\" xmlns:xsd1=\"http://common.mgt.user.carbon.wso2.org/xsd\"><soapenv:Header/><soapenv:Body><xsd:addUser><xsd:userName>$3</xsd:userName><xsd:password>$4</xsd:password>$5</xsd:addUser></soapenv:Body></soapenv:Envelope>" https://localhost:9443/services/UserAdmin.UserAdminHttpsSoap11Endpoint
}

# $1 tenantDomain
configure_tenant() {
	 
	if [[ 'carbon.super' != $1 ]]
	then
		add_tenant "admin" "admin" "$1" "admin@gmail.com" "fn" "ln"
		echo "\n"
	fi
	
	add_user "admin@$1" "admin" "creator" "creator" "<xsd:roles>Internal/creator</xsd:roles>"
	add_user "admin@$1" "admin" "publisher" "publisher" "<xsd:roles>Internal/publisher</xsd:roles>"
	add_user "admin@$1" "admin" "subscriber" "subscriber" "<xsd:roles>Internal/subscriber</xsd:roles>"
	add_user "admin@$1" "admin" "migration_user" "migration_user" "<xsd:roles>Internal/creator</xsd:roles><xsd:roles>Internal/publisher</xsd:roles><xsd:roles>Internal/subscriber</xsd:roles>"
	add_user "admin@$1" "admin" "migration_admin" "migration_admin" "<xsd:roles>admin</xsd:roles>"
}

#$1 path to deployment.toml
configure_application_attributes() {
	echo -e "\n\n[[apim.devportal.application_attributes]] \nrequired=false \nhidden=false \nname=\"External Reference Id\" \ndescription=\"Sample description of the attribute\"" >> $1
	echo "Added application attribute \"External Reference ID\"..."
}

while getopts v: option
do
case "${option}"
in
v) version=${OPTARG};;
esac
done

if [[ "3.1.0" == $version ]]
then
	setup_310
	
	echo "Start APIM server @ $APIM_310_HOME ..."
	echo "Confirm APIM 3.1.0 started(y/n)..."
	read shouldContinue
	
	if [[ "y" == $shouldContinue ]]
	then
		echo "Resuming to continue..."
		configure_tenant "carbon.super"
		configure_tenant "test.com"
		configure_tenant "wso2.com"
		
		configure_application_attributes "$APIM_310_HOME$PATH_TO_DEPLOYMENT_TOML"
	elif [[ "n" == $shouldContinue ]]
	then
		echo "Cannot continue without an APIM 3.10 running... Hence exiting"
	fi 

fi







