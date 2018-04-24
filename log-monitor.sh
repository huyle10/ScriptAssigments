#!/bin/bash

# Objective: in 30s, continuous search for a pattern in a log's new lines, then send email to itstaffcr

# Usage: (need crontab access)
# crontab */5 * * * * * /path/to/script.sh - automatically run script every 5 min - the script itself stops after 30s.

# One time run: ./scriptname.sh
# Cool trick - nohup to run script as a process
# nohup ./scriptname.sh 0<&- &>/dev/null &

EMAIL="hle@genevatrading.com"
LOG_FILE="/home/tgerman/log/alert-generator.log"
SEARCH="socket.timeout"
tail -n0 -F "$LOG_FILE" | \
while read -t 30 LINE ; do
  echo "$LINE" | grep -q "$SEARCH"
  if [ $? = 0 ]
  then
    # echo "Found"
    mail -v -s "This is the subject: Galert" "$EMAIL" <<< echo "${LINE}"
    exit 0
  fi
done
