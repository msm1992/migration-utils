#!/bin/bash
marketing_api_id=""
sales_api_id=""
username="admin"
password="admin"

# $1 categopry name
# $2 description
add_api_category() {
	credentials=$(echo "$username:$password" | base64)
	curl -X POST -k https://localhost:9443/api/am/admin/v0.16/api-categories -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{\"name\":\"$1\", \"description\":\"$2\"}"
}

add_test_apis() {
	credentials=$(echo "$username:$password" | base64)

	marketing_api_id=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"MarketingCategoryTest\", \"description\": \"This is an API added to test API Categories\", \"context\": \"/marketing\", \"version\": \"1.0.0\", \"provider\": \"admin\", \"categories\": [\"Marketing\", \"Internal Affairs\"], \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"marketingTag\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false } }" | jq -r '.id')
	echo "Added Marketing(Category Test) API Successfully... "

	curl -X POST -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/publisher/v1/apis/change-lifecycle?apiId=$marketing_api_id&action=Publish"

	sales_api_id=$(curl -X POST -k "https://localhost:9443/api/am/publisher/v1/apis" -H "Authorization: Basic $credentials" -H "Content-Type: application/json" --data "{ \"name\": \"SalesCategoryTest\", \"description\": \"This is an API added to test API Categories\", \"context\": \"/sales\", \"version\": \"1.0.0\", \"provider\": \"admin\",  \"categories\": [\"Sales\", \"Internal Affairs\"], \"wsdlUrl\": null, \"lifeCycleStatus\": \"CREATED\", \"responseCachingEnabled\": false, \"cacheTimeout\": 300, \"destinationStatsEnabled\": false, \"isDefaultVersion\": false, \"transport\": [ \"http\", \"https\" ], \"tags\": [\"salesTag\"], \"policies\": [\"Unlimited\"], \"maxTps\": { \"sandbox\": 5000, \"production\": 1000 }, \"visibility\": \"PUBLIC\", \"visibleRoles\": [], \"visibleTenants\": [], \"endpointConfig\": { \"endpoint_type\": \"http\", \"sandbox_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" }, \"production_endpoints\": { \"url\": \"http://run.mocky.io/v3/f7509b51-5913-47f3-8813-88426fcf3fd4\" } }, \"gatewayEnvironments\": [\"Production and Sandbox\"], \"subscriptionAvailability\": null, \"subscriptionAvailableTenants\": [], \"businessInformation\": { \"businessOwnerEmail\": \"marketing@pizzashack.com\", \"technicalOwnerEmail\": \"architecture@pizzashack.com\", \"technicalOwner\": \"John Doe\", \"businessOwner\": \"Jane Roe\" }, \"corsConfiguration\": { \"accessControlAllowOrigins\": [\"*\"], \"accessControlAllowHeaders\": [ \"authorization\", \"Access-Control-Allow-Origin\", \"Content-Type\", \"SOAPAction\" ], \"accessControlAllowMethods\": [ \"GET\", \"PUT\", \"POST\", \"DELETE\", \"PATCH\", \"OPTIONS\" ], \"accessControlAllowCredentials\": false, \"corsConfigurationEnabled\": false } }" | jq -r '.id')
	echo "Added Sales(Category Test) API Successfully... "

	curl -X POST -k -H "Authorization: Basic $credentials" -H "Content-Type: application/json" "https://localhost:9443/api/am/publisher/v1/apis/change-lifecycle?apiId=$sales_api_id&action=Publish"
}


##ADD API CATEGORIES
add_api_category "Finance" "Finance related APIS"
add_api_category "Marketing" "Marketing related APIS"
add_api_category "RnD" "RnD related APIS"
add_api_category "Sales" "Sales related APIS"
add_api_category "Distribution" "Distribution related APIS"
add_api_category "HR" "HR related APIS"
add_api_category "Engineering" "Engineering related APIS"
add_api_category "Design" "Design related APIS"
add_api_category "Management" "Management related APIS"
add_api_category "Publications" "Publications related APIS"
add_api_category "Orders" "Orders related APIS"
add_api_category "Weather" "Weather related APIS"
add_api_category "Phone Book" "Phone Book related APIS"
add_api_category "Internal Affairs" "Internal Affairs related APIS"
add_api_category "Property" "Property related APIS"

add_test_apis "publisher" "publisher"

##CONFIGURE FOR TENANT
username="admin@test.com"
password="admin"
add_api_category "Finance" "Finance related APIS"
add_api_category "Marketing" "Marketing related APIS"
add_api_category "RnD" "RnD related APIS"
add_api_category "Sales" "Sales related APIS"
add_api_category "Distribution" "Distribution related APIS"
add_api_category "HR" "HR related APIS"
add_api_category "Engineering" "Engineering related APIS"
add_api_category "Design" "Design related APIS"
add_api_category "Management" "Management related APIS"
add_api_category "Publications" "Publications related APIS"
add_api_category "Orders" "Orders related APIS"
add_api_category "Weather" "Weather related APIS"
add_api_category "Phone Book" "Phone Book related APIS"
add_api_category "Internal Affairs" "Internal Affairs related APIS"
add_api_category "Property" "Property related APIS"

add_test_apis "publisher@test.com" "publisher"
