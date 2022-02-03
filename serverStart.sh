#!/bin/bash

# Copyright (c) 2022 Synopsys, Inc. All rights reserved worldwide.
# Start the process specified in startCmd argument
# Create a log file in /tmp
# Watch the log for serverStarted string and return the PID of the running process
# Note: Make sure you are specifying the correct string to search for. Note: Maven will add its own colour which
# can cause the search string to not be found.

wait_str() {
    local file="$1"; shift
    local search_term="$1"; shift
    local wait_time="${1:-5m}"; shift # 5 minutes as default timeout

    (timeout $wait_time tail -F -n0 "$file" &) | grep -q "$search_term" && return 0

    echo "Timeout of $wait_time reached. Unable to find '$search_term' in '$file'"
    return 1
}

wait_server() {
    echo "Waiting for server..."
    local server_log="$1"; shift
    local started_text="$1"; shift
    local wait_time="$1"; shift

    wait_file "$server_log" 10 || { echo "Server log file missing: '$server_log'"; return 1; }

    wait_str "$server_log" "Started Jetty Server" "$wait_time"
}

wait_file() {
    local file="$1"; shift
    local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

    until test $((wait_seconds--)) -eq 0 -o -f "$file" ; do sleep 1; done

    ((++wait_seconds))
}

for i in "$@"; do
    case "$i" in
        --startCmd=*) startCmd="${i#*=}" ;;
        --startedString=*) startedString="${i#*=}" ;;
        --project=*) project="${i#*=}" ;;
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

#Split $startCmd into operation and operands
commandArray=($startCmd)
startOperation=$commandArray
for (( n=1; n < ${#commandArray[*]}; n++))
do
    startOperands="$startOperands ${commandArray[n]}"
done

output=$(mktemp /tmp/$project.XXX)
($startOperation $startOperands >$output 2>/dev/null) &
serverPID=$!

if (! wait_server $output "$startedString" 60s); then
    echo "Could not start server"
    exit 1
fi

echo $serverPID
exit 0

