#!/bin/bash

source ./app_utils.sh

#ADD TEST API
add_hello_world_api "admin" "admin"


##ADD APPLICATIONS, SUBSCRIBE TO API AND GENERATE TOKENS
add_application "admin" "admin" "TestApp" "JWT" "" false ""
subscribe_to_api "admin" "admin"
register_oauth_app "admin" "admin" "PRODUCTION"
register_oauth_app "admin" "admin" "SANDBOX"

add_application "admin" "admin" "TestAppWithAttribute" "JWT" "2563898" false ""
subscribe_to_api "admin" "admin"
register_oauth_app "admin" "admin" "PRODUCTION"
register_oauth_app "admin" "admin" "SANDBOX"

add_application "admin" "admin" "OauthTypeTestApp" "OAUTH" "" false ""
subscribe_to_api "admin" "admin"
register_oauth_app "admin" "admin" "PRODUCTION"
register_oauth_app "admin" "admin" "SANDBOX"

add_application "admin" "admin" "TestAppWithTokenHash" "JWT" "" true ""
subscribe_to_api "admin" "admin"
register_oauth_app "admin" "admin" "PRODUCTION"
register_oauth_app "admin" "admin" "SANDBOX"

