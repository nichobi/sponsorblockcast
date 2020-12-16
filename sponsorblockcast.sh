#!/bin/sh

SBCPOLLINTERVAL="${SBCPOLLINTERVAL:-30}"
SBCSCANINTERVAL="${SBCSCANINTERVAL:-300}"
SBCDIR="${SBCDIR:-/tmp/sponsorblockcast}"
SBCCATEGORIES="${SBCCATEGORIES:-sponsor}"

# Format categories for curl by quoting words, replacing spaces with commas and surrounding with escaped brackets
categories="\\[$(echo "$SBCCATEGORIES" | sed 's/[^ ]\+/"&"/g;s/\s/,/g')\\]"

[ -e "$SBCDIR" ] && rm -r "$SBCDIR"
mkdir "$SBCDIR" || exit 1
cd    "$SBCDIR" || exit 1

get_segments () {
  id=$1
  if [ ! -f "$id".segments ]
  then
    curl -fs "https://sponsor.ajay.app/api/skipSegments?videoID=$id&categories=$categories" |\
    jq -r '.[] | (.segment|map_values(tostring)|join(" ")) + " " + .category' > "$id.segments"
  fi
}

check () {
  uuid=$1
  status=$(go-chromecast status -u "$uuid")
  state=$(echo "$status" | grep -oP '\(\K[^\)]+')
  [ "$state" != "PLAYING" ] && return
  video_id=$(echo "$status" | grep -oP '\[\K[^\]]+')
  echo Chromecast is "$state"
  get_segments "$video_id"
  progress=$(echo "$status" | grep -oP 'remaining=\K[^s]+')
  while read -r start end category; do
    if [ "$(echo "($progress > $start) && ($progress < ($end - 5))" | bc)" -eq 1 ]
    then
      echo "Skipping $category from $start -> $end"
      go-chromecast -u "$uuid" seek-to "$end"
    else
      delta=$(echo "$start - $progress" | bc)
      echo delta="$delta"
      if [ "$(echo "($delta < $max_sleep_time) && ($delta > 0)" | bc)" -eq 1 ]
      then
        max_sleep_time=$(echo "$delta / 1" | bc)
      fi
    fi
  done < "$video_id.segments"
}


scan_chromecasts() {
  current_time=$(date +%s)
  if [ -z "$last_scan" ] || [ "$last_scan" -lt "$((current_time - SBCSCANINTERVAL))" ]
  then
    go-chromecast ls | grep -oP 'uuid="\K[^"]+' > devices
    last_scan=$current_time
  fi
}

while :
do
  scan_chromecasts
  max_sleep_time=$SBCPOLLINTERVAL
  while read -r uuid; do
    echo checking "$uuid"
    check "$uuid"
  done < devices
  echo sleeping "$max_sleep_time" seconds
  sleep "$max_sleep_time"
done

