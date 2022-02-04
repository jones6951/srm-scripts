#!/bin/bash

if [[ $1 == ?(-)+([0-9]) ]]; then
  exit 0
else
  exit 1
fi
