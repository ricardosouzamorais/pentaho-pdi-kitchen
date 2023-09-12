#!/bin/bash

# Creating paths if volume mounted does not have it
if [ ! -d "/app/results/data/" ]; then
  mkdir -p /app/results/data
fi 

if [ ! -d "/app/results/logs/" ]; then
  mkdir -p /app/results/logs
fi 

# Copy extra libs to pentaho
cp -pr /app/pentaho-extra-libs/* /opt/pentaho/lib

find /opt/pentaho

JOB_NAME=$(find /app/jobs -type f -iname '*.kjb' -exec basename {} \;)

echo "==============================================="
echo "Starting kitchen.sh for running a job in PDI..."
echo "-----------------------------------------------"
echo "JOB_NAME = $JOB_NAME"
echo "JOB FILE = /app/jobs/${JOB_NAME}"
echo "LOG FILE = /app/results/logs/${JOB_NAME}.log"
echo "APP_LOG_LEVEL = $APP_LOG_LEVEL"
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
  -file="/app/jobs/${JOB_NAME}" \
  -logfile="/app/results/logs/${JOB_NAME}.log" \
  -level=$APP_LOG_LEVEL \
  "$@" # Passing all other parameters received

EXITCODE=$?
echo "-----------------------------------------------"
echo "Getting out entrypoint.sh with exitcode: $EXITCODE"

echo "==============================================="