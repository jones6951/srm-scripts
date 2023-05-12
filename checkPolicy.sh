#!/bin/sh

# Copyright (c) 2023 Synopsys, Inc. All rights reserved worldwide.

for i in "$@"; do
    case "$i" in
    --url=*) url="${i#*=}" ;;
    --apikey=*) apikey="${i#*=}" ;;
    --project=*) project="${i#*=}";;
    --branch=*) branch="${i#*=}" ;;
    --policy=*) policy="${i#*=}" ;;
    *) ;;
    esac
done

if [ -z "$project" ]; then
    echo "You must specify a Project"
    echo "Usage: checkPolicy.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH --policy=POLICY"
    exit 1
fi
if [ -z "$branch" ]; then
    echo "You must specify a Branch"
    echo "Usage: checkPolicy.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH --policy=POLICY"
    exit 1
fi
if [ -z "$url" ]; then
    echo "You must specify a URL"
    echo "Usage: checkPolicy.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH --policy=POLICY"
    exit 1
fi
if [ -z "$apikey" ]; then
    echo "You must specify an APIKEY"
    echo "Usage: checkPolicy.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH --policy=POLICY"
    exit 1
fi

projectID=$(curl -k -s -X 'GET' "$url/codedx/api/projects" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".projects[] | select(.name==\"$project\").id")
if [ -z $projectID ]; then
    echo "Project not found"
    exit 1
fi

branchID=$(curl -k -s -X 'GET' "$url/codedx/x/projects/$projectID/branches" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".[].id")

policyStatus=$(curl -k -s -X 'GET' "$url/codedx/api/projects/$projectID;branchId=$branchID/policies/$policy/build-broken" -H 'accept: application/json' -H "API-Key: $apikey")
if [ -z $projectID ]; then
    echo "Policy not found"
    exit 1
fi

echo $policyStatus

exit 0

