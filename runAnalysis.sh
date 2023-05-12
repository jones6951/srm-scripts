#!/bin/sh

# Copyright (c) 2023 Synopsys, Inc. All rights reserved worldwide.

for i in "$@"; do
    case "$i" in
    --url=*) url="${i#*=}" ;;
    --apikey=*) apikey="${i#*=}" ;;
    --project=*) project="${i#*=}";;
    --branch=*) branch="${i#*=}" ;;
    *) ;;
    esac
done

if [ -z "$project" ]; then
    echo "You must specify a Project"
    echo "Usage: runAnalysis.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH"
    exit 1
fi
if [ -z "$branch" ]; then
    echo "You must specify a Branch"
    echo "Usage: runAnalysis.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH"
    exit 1
fi
if [ -z "$url" ]; then
    echo "You must specify a URL"
    echo "Usage: runAnalysis.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH"
    exit 1
fi
if [ -z "$apikey" ]; then
    echo "You must specify an APIKEY"
    echo "Usage: runAnalysis.sh --url=URL --apikey=APIKEY --project=PROJECT --branch=BRANCH"
    exit 1
fi

projectID=$(curl -k -s -X 'GET' "$url/codedx/api/projects" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".projects[] | select(.name==\"$project\").id")
if [ -z $projectID ]; then
    echo "Project not found"
    exit 1
fi

runStatus=$(curl -k -s -X 'POST' "$url/codedx/api/projects/$projectID;branch=$branch/analysis" -H 'accept: application/json' -H "API-Key: $apikey" --form 'filenames=""' --form 'includeGitSource="true"' --form 'gitBranchName=""' --form 'branchName=""')

echo $runStatus

exit 0
