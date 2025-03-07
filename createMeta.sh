#!/bin/sh

# Copyright (c) 2025 Black Duck Software. All rights reserved worldwide.

for i in "$@"; do
    case "$i" in
    --url=*) url="${i#*=}" ;;
    --token=*) token="${i#*=}" ;;
    *) ;;
    esac
done

if [ -z "$url" ]; then
    echo "You must specify a URL"
    echo "Usage: createMeta.sh --url --token"
    exit 1
fi
if [ -z "$token" ]; then
    echo "You must specify a Personal Access Token"
    echo "Usage: createMeta.sh --url --token"
    exit 1
fi

metadata='[{
  "name": "Risk",
  "type": "enum",
  "values": [
    {
      "valueId": "high",
      "value": "High"
    },
    {
      "valueId": "medium",
      "value": "Medium"
    },
    {
      "valueId": "low",
      "value": "Low"
    }
  ]
}]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Application Type",
    "type": "enum",
    "values": [
      {
        "valueId": "Financial",
        "value": "Financial"
      },
      {
        "valueId": "DMZ",
        "value": "DMZ"
      }
    ]
  }
]'
result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "SOX Compliant",
    "type": "enum",
    "values": [
      {
        "valueId": "true",
        "value": "True"
      },
      {
        "valueId": "false",
        "value": "False"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Protected Personal Information",
    "type": "enum",
    "values": [
      {
        "valueId": "true",
        "value": "True"
      },
      {
        "valueId": "false",
        "value": "False"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Material Non-Public Information",
    "type": "enum",
    "values": [
      {
        "valueId": "true",
        "value": "True"
      },
      {
        "valueId": "false",
        "value": "False"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Classification of Information",
    "type": "enum",
    "values": [
      {
        "valueId": "Highly_Restricted",
        "value": "Highly Restricted"
      },
      {
        "valueId": "Restricted",
        "value": "Restricted"
      },
      {
        "valueId": "Internal",
        "value": "Internal"
      },
      {
        "valueId": "Public",
        "value": "Public"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Customer Facing",
    "type": "enum",
    "values": [
      {
        "valueId": "true",
        "value": "True"
      },
      {
        "valueId": "false",
        "value": "False"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Externally Facing",
    "type": "enum",
    "values": [
      {
        "valueId": "true",
        "value": "True"
      },
      {
        "valueId": "false",
        "value": "False"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Asset Tier",
    "type": "enum",
    "values": [
      {
        "valueId": "Tier 01",
        "value": "Tier 1"
      },
      {
        "valueId": "Tier 02",
        "value": "Tier 2"
      },
      {
        "valueId": "Tier 03",
        "value": "Tier 3"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

metadata='[
  {
    "name": "Fair Lending",
    "type": "enum",
    "values": [
      {
        "valueId": "true",
        "value": "True"
      },
      {
        "valueId": "false",
        "value": "False"
      }
    ]
  }
]'

result=$(curl -s -X 'POST' "$url/srm/api/project-fields" -H 'accept: application/json' -H "API-Key: $token" -H 'Content-Type: application/json' -d "$metadata")
echo "Result = [$result]"

exit 0
