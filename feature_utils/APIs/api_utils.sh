#!/bin/bash
temp_api_id=""
PATH_TO_CUSTOM_AUTH_HEADER_SEQ="/home/sachini/wso2/2020/3.2.0_migration/3.1-3.2_migration_tests/utils/feature_utils/APIs/resources/custom_auth_token.xml"

add_hello_world_api() {
	echo "Starting..."
	credentials=$(echo "$1:$2" | base64)
	apiId=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"Hello\", \"description\": \"This is Hello World API\", \"context\": \"/hello\", \"version\": \"1.0.0\", \"provider\": \"admin\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"hello\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false } }" | jq -r '.id')
	echo "Hello API ID : $apiId"

	curl -X POST -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/publisher/v1/apis/change-lifecycle?apiId=$apiId&action=Publish"
}

# $1 api name
# $2 api context
add_mock_api() {
	echo "Starting..."
	credentials=$(echo "$username:$password" | base64)
	apiId=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"$1\", \"description\": \"This is $1 API\", \"context\": \"/$2\", \"version\": \"1.0.0\", \"provider\": \"admin\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"hello\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false } }" | jq -r '.id')
	echo "Mock API $1 ID : $apiId"
	temp_api_id=$apiId

	curl -X POST -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/publisher/v1/apis/change-lifecycle?apiId=$apiId&action=Publish"
}

attach_custom_auth_header_policy() {
	add_mock_api "TestCustomAuthHeader" "customauth"
	
	credentials=$(echo "$username:$password" | base64)
	
	policy_id=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis/$temp_api_id/mediation-policies" -H "Authorization: Basic $credentials" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" -F  "mediationPolicyFile=@$PATH_TO_CUSTOM_AUTH_HEADER_SEQ;type=text/xml" -F "type=in" | jq -r '.id')

	curl -X PUT -k "https://localhost:9443/api/am/publisher/v1/apis/$temp_api_id" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"TestCustomAuthHeader\", \"description\": \"This is TestCustomAuthHeader API\", \"context\": \"/customauth\", \"version\": \"1.0.0\", \"provider\": \"admin\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"hello\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false }, \"mediationPolicies\":
[{\"id\": \"$policy_id\", \"name\": \"custom_auth_token\", \"type\": \"IN\"}], \"operations\" : [{\"target\": \"/*\", \"verb\": \"GET\", \"authType\": \"Application & Application User\"}] }"
	
}

# $1 username
# $2 password
# $3 api name
get_api_by_name() {
	credentials=$(echo "$1:$2" | base64)
	api=$(curl -X GET -k "https://localhost:9443/api/am/publisher/v1/apis?query=name:$3" -H "Authorization: Basic $credentials" | jq -r '.list[0].id')
	echo $api
}

#$1 username
#$2 password
#$3 app id
#$4 throttle policy
#$5 api id
subscribe_to_api() {
	credentials=$(echo "$1:$2" | base64)
	curl -k -X POST -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{\"applicationId\" : \"$3\", \"throttlingPolicy\" : \"$4\", \"apiId\" : \"$5\"}" "https://localhost:9443/api/am/store/v1/subscriptions"
}

#$1 username
#$2 password
#$3 api id
#$4 lifecycle action
change_api_life_cycle() {
	credentials=$(echo "$1:$2" | base64)
	curl -X POST -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/publisher/v1/apis/change-lifecycle?apiId=$3&action=$4"
}

#add_hello_world_api "admin" "admin"
#attach_custom_auth_header_policy
#get_api_by_name "admin" "admin" "TestCustomAuthHeader"
    
