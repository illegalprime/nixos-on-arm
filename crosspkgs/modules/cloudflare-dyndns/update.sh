#!/usr/bin/env bash
set -euo pipefail

if [[ ! ${CF_AUTH_KEY:-} || ! ${CF_ZONE:-} || ! ${CF_RECORDS:-} ]]; then
    echo 'CF_AUTH_KEY, CF_ZONE, and CF_RECORDS must be defined!'
    exit 1
fi

# store key in a temporary file
exec 8<<< "Authorization: Bearer $(< ${CF_AUTH_KEY})"
AUTH_HEADER='@/dev/fd/8'
set -x

function get_zone() {
    curl \
        -s \
        -X GET \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/zones?name=$1"
}

function list_dns_records() {
    curl \
        -s \
        -X GET \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/zones/$1/dns_records"
}

function create_record() {
    curl \
        -s \
        -X POST \
        --data "$2" \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/zones/$1/dns_records"
}

function update_record() {
    curl \
        -s \
        -X PUT \
        --data "$3" \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/zones/$1/dns_records/$2"
}

# get public IP
EXTERNAL_IP=$(curl -s ipinfo.io | jq -r .ip)

# get the zone id
ZONE_ID=$(get_zone "$CF_ZONE")
[[ $(jq .success <<< "$ZONE_ID") == 'true' ]]
ZONE_ID=$(jq -r '.result | .[].id' <<< "$ZONE_ID")

# get all the records
DNS_RECORDS=$(list_dns_records "$ZONE_ID")
[[ $(jq .success <<< "$DNS_RECORDS") == 'true' ]]
mapfile -t DNS_RECORDS < <(jq -rc '.result | .[]' <<< "$DNS_RECORDS")

# read all the records we want to set
mapfile -t TARGET_RECORDS < <(jq -rc .[] < "$CF_RECORDS")

# set them all
for RECORD in ${TARGET_RECORDS[@]}; do
    RECORD=$(sed "s,@ip@,$EXTERNAL_IP,g" <<< "$RECORD")

    # check if the record exists already
    RECORD_ID='not-found'
    for CF_RECORD in ${DNS_RECORDS[@]}; do
        if [[ $(jq -r .name <<< "$CF_RECORD") == $(jq -r .name <<< "$RECORD") ]]
        then
            RECORD_ID=$(jq -r .id <<< "$CF_RECORD")
            break
        fi
    done

    # set or create the record
    if [[ "$RECORD_ID" == 'not-found' ]]; then
        RESULT=$(create_record "$ZONE_ID" "$RECORD")
    else
        RESULT=$(update_record "$ZONE_ID" "$RECORD_ID" "$RECORD")
    fi

    [[ $(jq .success <<< "$RESULT") == 'true' ]]
done

