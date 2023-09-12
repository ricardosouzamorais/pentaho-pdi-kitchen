#!/bin/bash

# Creating paths if volume mounted does not have it
if [ ! -d "/app/results/data/" ]; then
  mkdir -p /app/results/data
fi 

if [ ! -d "/app/results/logs/" ]; then
  mkdir -p /app/results/logs
fi 

JOB_NAME=$(find /app/jobs -type f -iname '*.kjb' -exec basename {} \;)

echo "==============================================="
echo "Starting kitchen.sh for running a job in PDI..."
echo "-----------------------------------------------"
echo "APP_JVM_MIN_MEMORY = $APP_JVM_MIN_MEMORY"
echo "APP_JVM_MAX_MEMORY = $APP_JVM_MAX_MEMORY"

echo "-----------------------------------------------"

echo "All arguments (args_count = $#) passed to the script:"
args_array=("$@")
for i in "${args_array[@]}"
do
  :
  echo "Argument: $i"
done

echo "-----------------------------------------------"

/opt/pentaho/kitchen.sh \
  "$@" # Passing all other parameters received

EXITCODE=$?
echo "-----------------------------------------------"
echo "Getting out entrypoint.sh with exitcode: $EXITCODE"

echo "==============================================="