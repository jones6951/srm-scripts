#!/bin/sh

# Copyright (c) 2025 Black Duck Software. All rights reserved worldwide.

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

if [ -z "$policy" ]; then
    policyID=any
else
    policyID=$(curl -k -s -X 'GET' "$url/srm/x/policies" -H 'accept: application/json' -H "API-Key: $apikey"| jq ".[] | select(.name==\"$policy\").id")
    if [ -z $policyID ]; then
        echo "Policy not found"
        exit 1
    fi
fi

projectID=$(curl -k -s -X 'GET' "$url/srm/api/projects" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".projects[] | select(.name==\"$project\").id")
if [ -z $projectID ]; then
    echo "Project not found"
    exit 1
fi
policyStatus=$(curl -k -s -X 'GET' "$url/srm/x/projects/$projectID;branch=$branch/policies/$policyID/build-broken" -H 'accept: application/json' -H "API-Key: $apikey")
if [ -z $policyStatus ]; then
    echo "Error"
    exit 1
fi

echo $policyStatus
if [ $policyStatus == "true" ]; then
    exit 1
fi
exit 0

