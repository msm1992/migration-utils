#!/bin/bash

# $1 username
# $2 password
add_custom_subs_policy() {
	credentials=$(echo "$1:$2" | base64)
	curl -k -X POST -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/admin/v0.16/throttling/policies/subscription" --data "{\"policyName\": \"CustomSubs\",\"displayName\": \"CustomSubs\",\"description\": \"Allows 5 requests per minute\",\"isDeployed\": true,\"defaultLimit\": {\"type\": \"RequestCountLimit\",\"timeUnit\": \"min\",\"unitTime\": 1,\"requestCount\": 5},\"rateLimitCount\": -1,\"rateLimitTimeUnit\": \"NA\",\"stopOnQuotaReach\": true,\"billingPlan\": \"FREE\"}"
}

add_custom_application_policy() {
	credentials=$(echo "$1:$2" | base64)
	curl -k -X POST -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/admin/v0.16/throttling/policies/application" --data "{\"policyName\": \"2PerMin\",\"displayName\": \"2PerMin\",\"description\": \"Allows 2 request per minute\",\"defaultLimit\": {\"type\": \"RequestCountLimit\",\"timeUnit\": \"min\",\"unitTime\": 1,\"requestCount\": 2}}"
}

add_test_api_with_subscription_level_throttling() {
	credentials=$(echo "$1:$2" | base64)
	local apiId=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"ThrottleTestAPI\", \"description\": \"This is Subscription Throttle Test API\", \"context\": \"/substhrottle\", \"version\": \"1.0.0\", \"provider\": \"$1\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"throttle\"], \"policies\": [\"Bronze\", \"Gold\", \"CustomSubs\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false }, \"operations\" : [{\"target\": \"/throttleres\", \"verb\": \"GET\", \"authType\": \"Application & Application User\"}, {\"target\": \"/throttleres2\", \"verb\": \"GET\", \"authType\": \"Application & Application User\"}] }" | jq -r '.id')
	echo $apiId
}

add_test_api() {
	credentials=$(echo "$1:$2" | base64)
	local apiId=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"ApplicationThrottleTestAPI\", \"description\": \"This is Application Throttle Test API\", \"context\": \"/appsthrottle\", \"version\": \"1.0.0\", \"provider\": \"$1\", \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"throttle\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false }, \"operations\" : [{\"target\": \"/throttleres\", \"verb\": \"GET\", \"authType\": \"Application & Application User\"}, {\"target\": \"/throttleres2\", \"verb\": \"GET\", \"authType\": \"Application & Application User\"}] }" | jq -r '.id')
	echo $apiId
}




