#!/bin/bash

##########
#
# Keeps a specific path up to date with a certain music channel, by downloading
#   and converting any new tracks to MP3 for consumption by another service.
# Sends a push notification when it runs and has new music (optional).
# Keeps track of downloaded tracks via a "download.log".
#
# The argument parser is quite dumb and liable to break.
#
##########

info() {
  if [[ $LOG_INFO -eq "1" ]]; then
    echo -e "$@"
  fi
}

debug() {
  if [[ $LOG_DEBUG -eq "1" ]]; then
    echo -e "$@"
  fi
}

help() {
  echo "./$(basename "${BASH_SOURCE[0]}") {OPTIONS}"
  echo "Options"
  echo -e "\t-w <id> | Your wirepusher.com ID (triggers notification on new tracks)"
  echo -e "\t-v      | Log info output"
  echo -e "\t-V      | Log debug output"
  echo -e "\t-h      | Show this help message and exit"
}

# Default value for options
LOG_INFO=0
LOG_DEBUG=0
WIRE_PUSHER_ID=""

while getopts ":vVw:h" opt; do
  case ${opt} in
    v )
      LOG_INFO=1
      ;;
    V )
      LOG_INFO=1
      LOG_DEBUG=1
      ;;
    w )
      WIRE_PUSHER_ID="$OPTARG"
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

debug "LOG_INFO: $LOG_INFO\nLOG_DEBUG: $LOG_DEBUG\nWIRE_PUSHER_ID: ${WIRE_PUSHER_ID:-(not set)}"

count_files() {
  find . -maxdepth 1 -type f -iname '*.mp3' | wc -l
}

before_filecount=$(count_files)

debug "Files: $before_filecount"

info "Scraping channel..."
/usr/local/bin/youtube-dl --no-progress --no-config --continue --ignore-errors --no-overwrites --output "%(title)s-%(id)s.%(ext)s" --audio-format mp3 --extract-audio --format bestaudio --download-archive downloaded.log "https://www.youtube.com/c/LofiGirl"
# sleep 5
info "Channel scraped."

after_filecount=$(count_files)

debug "Before: $before_filecount, After: $after_filecount"

new_filecount=$((after_filecount - before_filecount))

if [[ $before_filecount -eq $after_filecount ]]; then
  info "Downloaded $new_filecount new tracks, total tracks $after_filecount"
  if [[ -n "$WIRE_PUSHER_ID" ]]; then
    curl --silent -o /dev/null -G "https://wirepusher.com/send" --data-urlencode "id=$WIRE_PUSHER_ID" --data-urlencode "title=New toons!" --data-urlencode "message=Downloaded $new_filecount new tracks."
  fi
else
  info "No new tracks detected"
fi
