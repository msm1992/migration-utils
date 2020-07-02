#!/bin/bash

appID=""
appData=""
apiId=""

#$1 username
#$2 password
#$3 app name
#$4 token type
#$5 attribute
#$6 hashEnabled
#$7 groups
add_application() {
	credentials=$(echo "$1:$2" | base64)

	appId=$(curl -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" -X POST --data "{\"throttlingPolicy\": \"Unlimited\", \"description\":\"sample app description\", \"name\":\"$3\", \"tokenType\":\"$4\", \"attributes\":{\"External Reference Id\": \"$5\"}, \"hashEnabled\":$6, \"groups\":[$7] }" "https://localhost:9443/api/am/store/v1/applications" | jq -r  '.applicationId')
	
	echo "Application $3 created Successfully with application ID $appId..."
	appData=""
	appData="App Name : $3, App ID : $appId"

}

#$1 username
#$2 password
#$3 app name
#$4 token type
#$5 app throttle policy
add_basic_application() {
	credentials=$(echo "$1:$2" | base64)
	
	if [[ -z $5 ]]
	then 
		local app_response=$(curl -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" -X POST --data "{\"throttlingPolicy\": \"Unlimited\", \"description\":\"sample app description\", \"name\":\"$3\", \"tokenType\":\"$4\"}" "https://localhost:9443/api/am/store/v1/applications" | jq -r  '.')
	else 
		local app_response=$(curl -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" -X POST --data "{\"throttlingPolicy\": \"$5\", \"description\":\"sample app description\", \"name\":\"$3\", \"tokenType\":\"$4\"}" "https://localhost:9443/api/am/store/v1/applications" | jq -r  '.')
	fi
	
	echo $app_response

}

#$1 username
#$2 password
#$3 Key Type (PRODUCTION/SANDBOX)
#$4 application ID
#$5 scopes
#$6 validity time
register_oauth_app() {
	credentials=$(echo "$1:$2" | base64)
	local token_response=$(curl -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" -X POST --data "{\"keyType\": \"$3\", \"grantTypesToBeSupported\":[\"refresh_token\",\"urn:ietf:params:oauth:grant-type:saml2-bearer\",\"password\",\"client_credentials\",\"iwa:ntlm\",\"urn:ietf:params:oauth:grant-type:device_code\",\"urn:ietf:params:oauth:grant-type:jwt-bearer\"], \"scopes\": $5, \"validityTime\": \"$6\" }" "https://localhost:9443/api/am/store/v1/applications/$4/generate-keys")
 
	echo $token_response
}

#$1 username
#$2 password
#$3 application id
#$4 Key Type
#$5 consumer secret 
#$6 consumer key
#$7 validity period
#$8 scopes
generate_token() {
	credentials=$(echo "$1:$2" | base64)
	curl -k -X POST "https://localhost:9443/api/am/store/v1/applications/$3/keys/$4/generate-token" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{\"consumerSecret\":\"$5\",\"validityPeriod\":\"$7\", \"scopes\":$8 }"
}

#$1 username
#$2 password
add_hello_world_api() {
	credentials=$(echo "$1:$2" | base64)
	apiId=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"Hello\", \"description\": \"This is Hello World API\", \"context\": \"/hello\", \"version\": \"1.0.0\", \"provider\": \"admin\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"hello\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false } }" | jq -r '.id')
	echo "Added Hello World API Successfully... "

	curl -X POST -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/publisher/v1/apis/change-lifecycle?apiId=$apiId&action=Publish"
}

