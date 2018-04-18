#!/bin/bash

# Objective: to look timed out service in log. Scripts will run periodically every 5 mins, 30s each period. Use crontab */5 * * * * /path/to/script.sh

LOG_FILE="/home/tgerman/log/alert-generator.log"
SEARCH="socket.timeout"
tail -n0 -F "$LOG_FILE" | \
while read -t 30 LINE ; do
  echo "$LINE" | grep -q "$SEARCH"
  if [ $? = 0 ]
  then
    # echo "Found"
    mail -v -s "This is the subject: Galert" hle@genevatrading.com <<< echo "${Line}"
    exit 0
  fi
done
