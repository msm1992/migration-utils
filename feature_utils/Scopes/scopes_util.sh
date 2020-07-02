#!/bin/bash

username="migration_user"
password="migration_user"

# $1 username
# $2 password
add_scope_test_api() {
	credentials=$(echo "$1:$2" | base64)
	apiId=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"ScopeTestAPI\", \"description\": \"This is Local ScopeTestAPI API\", \"context\": \"/scope\", \"version\": \"1.0.0\", \"provider\": \"migration_user\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"hello\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false }, \"scopes\": [{\"name\": \"TestScope\", \"description\": \"This is a Test Scope\", \"bindings\": {\"type\": \"role\", \"values\": [\"Internal/publisher\"]}}], \"operations\" : [{\"target\": \"/scopeProtected\", \"verb\": \"GET\", \"authType\": \"Application & Application User\", \"scopes\" : [\"TestScope\"]}, {\"target\": \"/scopeFree\", \"verb\": \"GET\", \"authType\": \"Application & Application User\"}] }" | jq -r '.id')	
	echo $apiId
}

add_application() {
	credentials=$(echo "$username:$password" | base64)

	app_id=$(curl -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" -X POST --data "{\"throttlingPolicy\": \"Unlimited\", \"description\":\"sample app description\", \"name\":\"ScopeTestApp\", \"tokenType\":\"OAUTH\", \"attributes\":{\"External Reference Id\": \"124536\"}, \"hashEnabled\":false, \"groups\":[] }" "https://localhost:9443/api/am/store/v1/applications" | jq -r  '.applicationId')
	
	echo "Application ScopeTestApp created Successfully with application ID $app_id..."	
}

subscribe() {
	credentials=$(echo "$username:$password" | base64)
	curl -k -X POST -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{\"applicationId\" : \"$app_id\", \"throttlingPolicy\" : \"Unlimited\", \"apiId\" : \"$api_id\"}" "https://localhost:9443/api/am/store/v1/subscriptions"
}

generate_keys() {
	credentials=$(echo "$username:$password" | base64)
	access_token=$(curl -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" -X POST --data "{\"keyType\": \"OAUTH\", \"grantTypesToBeSupported\":[\"refresh_token\",\"urn:ietf:params:oauth:grant-type:saml2-bearer\",\"password\",\"client_credentials\",\"iwa:ntlm\",\"urn:ietf:params:oauth:grant-type:device_code\",\"urn:ietf:params:oauth:grant-type:jwt-bearer\"] }" "https://localhost:9443/api/am/store/v1/applications/$app_id/generate-keys" | jq -r '.token.accessToken')
 
	echo $token_response
	appData="$appData$token_response\n"

	echo $appData >> app_data.txt
}

# $1 username
# $2 password
# $3 api name
get_api_by_name() {
	credentials=$(echo "$1:$2" | base64)
	api_id=$(curl -X GET -k "https://localhost:9443/api/am/publisher/v1/apis?query=name:$3" -H "Authorization: Basic $credentials" | jq -r '.list[0].id')
	echo $api_id
}

add_scope() {	
	get_api_by_name "admin" "admin" "TestCustomAuthHeader"
}

#add_scope_test_api
#add_application
#subscribe

