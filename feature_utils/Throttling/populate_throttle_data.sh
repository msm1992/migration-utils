#!/bin/bash

source ../APIs/api_utils.sh
source ../Applications/app_utils.sh
source ./throttle_utils.sh

api_id=""

# $1 tenantDomain with @
# $2 KeyType
# $3 app name
# $4 setup (true/false defines whether the api and sub policy should be added)
populate_throttle_data() {
	printf '%s\n\n' "SUBSCRIPTION THROTTLE DATA" >> throttle_data.txt

	if [[ true == $4 ]]
	then
		add_custom_subs_policy "migration_admin$1" "migration_admin"
		api_id=$(add_test_api_with_subscription_level_throttling "migration_user$1" "migration_user")
		change_api_life_cycle "migration_user$1" "migration_user" "$api_id" "Publish"
	fi

	app_resp=$(add_basic_application "migration_user$1" "migration_user" "$3" "$2")
	app_id=$(echo $app_resp | jq -r '.applicationId')
	subscribe_to_api "migration_user$1" "migration_user" "$app_id" "CustomSubs" "$api_id" 
	token_resp=$(register_oauth_app "migration_user$1" "migration_user" "PRODUCTION" "$app_id" "[]" "-1")
	printf '%s\n' "$1 $2 App Keys for Subscription Throttle Testing (This key should not allow to invoke api more than 5 per min)" >> throttle_data.txt
	printf '%s\n' "$token_resp" >> throttle_data.txt
}

# $1 tenantDomain with @
# $2 KeyType
# $3 app name
# $4 setup (true/false defines whether the api and sub policy should be added)
# $6 username
populate_app_throttle_data() {
	printf '%s\n\n' "APPLICATION THROTTLE DATA" >> throttle_data.txt
	if [[ true == $4 ]]
	then	
		api_id=$(add_test_api "migration_user$1" "migration_user")
		change_api_life_cycle "migration_user$1" "migration_user" "$api_id" "Publish"
		add_custom_application_policy "migration_admin$1" "migration_admin"
	fi

	app_resp=$(add_basic_application "migration_user$1" "migration_user" "$3" "$2" "2PerMin")
	app_id=$(echo $app_resp | jq -r '.applicationId')
	subscribe_to_api "migration_user$1" "migration_user" "$app_id" "Unlimited" "$api_id" 
	token_resp=$(register_oauth_app "migration_user$1" "migration_user" "PRODUCTION" "$app_id" "[]" "-1")
	printf '%s\n' "$1 $2 App Keys for Application Throttle Testing (This key should not allow to invoke api more than 2 per min)" >> throttle_data.txt
	printf '%s\n' "$token_resp" >> throttle_data.txt
}

> throttle_data.txt
#populate_throttle_data "" "OAUTH" "SubThrottleTestAppOauth" true
#populate_throttle_data "" "JWT" "SubThrottleTestAppJWT" false
populate_throttle_data "@test.com" "OAUTH" "SubThrottleTestAppOauth" true
populate_throttle_data "@test.com" "JWT" "SubThrottleTestAppJWT" false

#populate_app_throttle_data "" "OAUTH" "AppThrottleTestAppOauth" true
#populate_app_throttle_data "" "JWT" "AppThrottleTestAppJWT" false
populate_app_throttle_data "@test.com" "OAUTH" "AppThrottleTestAppOauth" true "migration_user@test.com"
populate_app_throttle_data "@test.com" "JWT" "AppThrottleTestAppJWT" false "migration_user@test.com"


