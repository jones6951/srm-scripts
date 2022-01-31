#!/bin/sh

# Copyright (c) 2022 Synopsys, Inc. All rights reserved worldwide.

for i in "$@"; do
    case "$i" in
        --startCmd=*) startCmd="${i#*=}" ;;
        --startedString=*) startedString="${i#*=}" ;;
        --project=*) project="${i#*=}" ;;
        --workingDir=*) workingDir="${i#*=}" ;;
    esac
done

if [ -z "$startCmd" ]; then
    echo "You must specify startCmd"
    echo "Usage: serverStart.sh --startCmd=COMMAND_TO_START_SERVER --startedString=SERVER_STARTED_MESSAGE --project=PROJECT --workingDir=WORKING_DIR"
    exit 1
fi

if [ -z "$startedString" ]; then
    echo "You must specify startedString"
    echo "Usage: serverStart.sh --startCmd=COMMAND_TO_START_SERVER --startedString=SERVER_STARTED_MESSAGE --project=PROJECT --workingDir=WORKING_DIR"
    exit 1
fi

if [ -z "$project" ]; then
    echo "You must specify project"
    echo "Usage: serverStart.sh --startCmd=COMMAND_TO_START_SERVER --startedString=SERVER_STARTED_MESSAGE --project=PROJECT --workingDir=WORKING_DIR"
    exit 1
fi

if [ $workingDir ]; then
    cd $workingDir
fi

output=$(mktemp /tmp/$project.XXX)
sh -c "$startCmd" &>$output &
serverPID=$!

until fgrep -q "$startedString" $output
do
    if ! ps $serverPID > /dev/null; then
        echo "Unable to start server" >&2
        exit 1
    fi
    sleep 1
done

if [ $workingDir ]; then
    cd -
fi

exit $serverPID
