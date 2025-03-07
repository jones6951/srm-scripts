#!/bin/sh

# Copyright (c) 2025 Black Duck Software. All rights reserved worldwide.

for i in "$@"; do
    case "$i" in
    --url=*) url="${i#*=}" ;;
    --apikey=*) apikey="${i#*=}" ;;
    --project=*) project="${i#*=}" ;;
    *) ;;
    esac
done

if [ -z "$url" ]; then
    echo "You must specify a URL"
    echo "Usage: getProjectID.sh --url --apikey --project"
    exit 1
fi
if [ -z "$apikey" ]; then
    echo "You must specify an API key"
    echo "Usage: getProjectID.sh --url --apikey --project"
    exit 1
fi
if [ -z "$project" ]; then
    echo "You must specify a project"
    echo "Usage: getProjectID.sh --url --apikey --project"
    exit 1
fi

projectID=$(curl -k -s -X 'GET' "$url/srm/api/projects" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".projects[] | select(.name==\"$project\").id")
if [ -z $projectID ]; then
    echo "Project not found"
    exit 1
fi

echo $projectID

exit 0
