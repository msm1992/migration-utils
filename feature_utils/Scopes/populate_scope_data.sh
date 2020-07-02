#!/bin/bash

source ./scopes_util.sh
source ../Applications/app_utils.sh
source ../APIs/api_utils.sh

#$1 username
#$2 password
populate_scope_data() {
	api_id=$(add_scope_test_api "$1" "$2")
	change_api_life_cycle "$1" "$2" "$api_id" "Publish"
	echo "Added ScopeTestAPI successfully...."

	app_resp=$(add_basic_application "$1" "$2" "ScopeTestApp" "OAUTH")
	app_id=$(echo $app_resp | jq -r '.applicationId')
	echo "Added ScopeTestApp successfully...."
	
	subscribe_to_api "$1" "$2" "$app_id" "Unlimited" "$api_id" 	
	echo "Added subscription successfully...."

	printf '%s\n' "Token Details for $1 user" >> scope_data.txt

	##get token with scope
	token_resp=$(register_oauth_app "$1" "$2" "PRODUCTION" "$app_id" "[\"TestScope\"]" "-1")
	consumer_key=$(echo $token_resp | jq -r '.consumerKey')
	consumer_secret=$(echo $token_resp | jq -r '.consumerSecret')
	printf '%s\n' "Token Response for Topken with Scope" >> scope_data.txt
	printf '%s\n' "$token_resp" >> scope_data.txt

	##generate token without scope

	token_resp=$(generate_token "$1" "$2" "$app_id" "PRODUCTION" "$consumer_secret" "$consumer_key" "-1" "[]" )
	printf '%s\n' "Token Response for Topken without Scope\n" >> scope_data.txt
	printf '%s\n' "$token_resp" >> scope_data.txt
}

populate_scope_data "migration_user" "migration_user"
populate_scope_data "migration_user@test.com" "migration_user"

