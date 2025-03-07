#!/bin/sh

# Copyright (c) 2025 Black Duck Software. All rights reserved worldwide.
# Requires jq to be installed.  https://stedolan.github.io/jq/

for i in "$@"; do
    case "$i" in
    --url=*) url="${i#*=}" ;;
    --apikey=*) apikey="${i#*=}" ;;
    --project=*) project="${i#*=}" ;;
    --branch=*) branch="${i#*=}" ;;
    *) ;;
    esac
done

if [ -z "$url" ]; then
    echo "You must specify a URL"
    echo "Usage: runAnalysis.sh --url --apikey --project --branch"
    exit 1
fi
if [ -z "$apikey" ]; then
    echo "You must specify an API key"
    echo "Usage: runAnalysis.sh --url --apikey --project --branch"
    exit 1
fi
if [ -z "$project" ]; then
    echo "You must specify a project name"
    echo "Usage: runAnalysis.sh --url --apikey --project --branch"
    exit 1
fi

projectID=$(curl -k -s -X 'GET' "$url/srm/api/projects" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".projects[] | select(.name==\"$project\").id")
if [ -z $projectID ]; then
    echo "Project not found"
    exit 1
fi

if [ -z "$branch" ]; then
#   Get the default branch
    branch=$(curl -k -s -X 'GET' "$url/srm/x/projects/$projectID/branches/default" -H 'accept: application/json' -H "API-Key: $apikey" | jq -r ".name")
fi

branchID=$(curl -k -s -X 'GET' "$url/srm/x/projects/$projectID/branches" -H 'accept: application/json' -H "API-Key: $apikey" | jq ".[] | select(.name==\"$branch\").id")
if [ -z $branchID ]; then
    echo "Branch not found"
    exit 1
fi

# Run the analysis
jobID=$(curl -k -s -X 'POST' "$url/srm/api/projects/$projectID;branchId=$branchID/analysis" -H 'accept: application/json' -H "API-Key: $apikey" --form 'filenames=""' --form 'includeGitSource="true"' --form 'gitBranchName=""' | jq -r ".jobId")

# Wait while the job is getting queued
while [ "$jobStatus" != "completed" ]; do
    jobStatus=$(curl -k -s -X 'GET' "$url/srm/api/jobs/$jobID" -H 'accept: application/json' -H "API-Key: $apikey"| jq -r ".status")
    sleep 5
done

if [ "$jobStatus" != "completed" ]; then
    echo "Analysis failed"
    exit 1
fi

analysisID=$(curl -k -s -X 'GET' "$url/srm/api/jobs/$jobID/result" -H 'accept: application/json' -H "API-Key: $apikey" | jq -r ".analysisId")

# Wait for the analysis to complete
analysisState="running"
while [ "$analysisState" = "running" ]; do
    analysisState=$(curl -k -s -X 'GET' "$url/srm/api/projects/$projectID/analyses/$analysisID" -H 'accept: application/json' -H "API-Key: $apikey" | jq -r ".state")
    sleep 5
done
if [ "$analysisState" != "complete" ]; then
    echo "Analysis failed"
    exit 1
fi

# Check if Build needs to be broken based on any policies
breakBuild=$(curl -k -s -X 'GET' "$url/srm/x/projects/$projectID;branch=$branch/policies/any/build-broken" -H 'accept: application/json' -H "API-Key: $apikey")
if [ "$breakBuild" = "true" ]; then
    echo "Breaking the build"
    exit 1
fi

exit 0