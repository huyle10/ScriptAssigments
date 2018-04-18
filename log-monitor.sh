#!/bin/bash
LOG_FILE="/home/tgerman/log/alert-generator.log"
SEARCH="twang"
tail -n0 -F "$LOG_FILE" | \
while read -t 30 LINE ; do
  echo "$LINE" | grep -q "$SEARCH"
  if [ $? = 0 ]
  then
    echo "Found"
    exit 0
  fi
done
