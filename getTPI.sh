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
    echo "Usage: getTPI.sh --url --apikey --project"
    exit 1
fi
if [ -z "$apikey" ]; then
    echo "You must specify an API key"
    echo "Usage: getTPI.sh --url --apikey --project"
    exit 1
fi
if [ -z "$project" ]; then
    echo "You must specify a project"
    echo "Usage: getTPI.sh --url --apikey --project"
    exit 1
fi

projectID=$(curl -s -X 'GET' "$url/srm/api/projects" -H 'accept: application/json' -H "API-Key: $apikey" |jq ".projects[] | select(.name==\"$project\").id")
if [ -z $projectID ]; then
    echo "Project not found"
    exit 1
fi

metadata=$(curl -s -X 'GET' "$url/srm/api/projects/$projectID/metadata"  -H 'accept: application/json' -H "API-Key: $apikey")

risk=$(echo $metadata |jq ".[] | select(.name==\"Risk\")".valueId)
assetType="Application"
applicationType=$(echo $metadata |jq ".[] | select(.name==\"Application Type\")".valueId)
applicationName=\"$project\",
soxFinancial=$(echo $metadata |jq ".[] | select(.name==\"SOX Compliant\")".valueId|sed 's/"//g')
ppi=$(echo $metadata |jq ".[] | select(.name==\"Protected Personal Information\")".valueId|sed 's/"//g')
mnpi=$(echo $metadata |jq ".[] | select(.name==\"Material Non-Public Information\")".valueId|sed 's/"//g')
infoClass=$(echo $metadata |jq ".[] | select(.name==\"Classification of Information\")".valueId)
customerFacing=$(echo $metadata |jq ".[] | select(.name==\"Customer Facing\")".valueId|sed 's/"//g')
externallyFacing=$(echo $metadata |jq ".[] | select(.name==\"Externally Facing\")".valueId|sed 's/"//g')
assetTier=$(echo $metadata |jq ".[] | select(.name==\"Asset Tier\")".valueId)
fairLending=$(echo $metadata |jq ".[] | select(.name==\"Fair Lending\")".valueId|sed 's/"//g')

echo "{
  \"assetId\": \"$project\",
  \"assetType\": \"Application\",
  \"applicationType\": $applicationType,
  \"applicationName\": \"$project\",
  \"applicationBuildName\": \"main-branch\",
  \"soxFinancial\": $soxFinancial,
  \"ppi\": $ppi,
  \"mnpi\": $mnpi,
  \"infoClass\": $infoClass,
  \"customerFacing\": $customerFacing,
  \"externallyFacing\": $externallyFacing,
  \"assetTier\": $assetTier,
  \"fairLending\": $fairLending
}"

exit 0
