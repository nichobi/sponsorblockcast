#!/bin/sh

SBCPOLLINTERVAL="${SBCPOLLINTERVAL:-30}"
SBCSCANINTERVAL="${SCANINTERVAL:-300}"
SBCDIR="${SBCDIR:-/tmp/sponsorblockcast}"

[ -e "$SBCDIR" ] && rm -r "$SBCDIR"
mkdir $SBCDIR
cd $SBCDIR || exit

getSegments () {
  id=$1
  [ ! -f "$videoid".segments ] && \
    curl -fs "https://sponsor.ajay.app/api/skipSegments?videoID=$id" |\
    jq -r '.[].segment|join(" ")' > "$videoid".segments
}

check () {
  uuid=$1
  status=$(go-chromecast status -u "$uuid")
  state=$(echo "$status" | grep -oP '\(\K[^\)]+')
  [ "$state" != "PLAYING" ] && return
  videoid=$(echo "$status" | grep -oP '\[\K[^\]]+')
  echo Chromecast is "$state"
  getSegments "$videoid"
  progress=$(echo "$status" | grep -oP 'remaining=\K[^s]+')
  while read -r start end; do
    if [ "$(echo "($progress > $start) && ($progress < ($end - 5))" | bc)" -eq 1 ]
    then
      go-chromecast -u "$uuid" seek-to "$end"
    else
      delta=$(echo "$start - $progress" | bc)
      echo delta="$delta"
      if [ "$(echo "($delta < $maxsleeptime) && ($delta > 0)" | bc)" -eq 1 ]
      then
        maxsleeptime=$(echo "$delta / 1" | bc)
      fi
    fi
  done < "$videoid.segments"
}

listChromecasts() {
  go-chromecast ls | while read -r line; do
    echo "$line" | grep -oP 'uuid="\K[^"]+'
  done
}

scanChromecasts() {
  currentTime=$(date +%s)
  if [ -z "$lastScan" ] || [ "$lastScan" -lt "$((currentTime - SBCSCANINTERVAL))" ]
  then
    listChromecasts > devices
    lastScan=$currentTime
  fi
}

while :
do
  scanChromecasts
  maxsleeptime=$SBCPOLLINTERVAL
  while read -r uuid; do
    echo checking "$uuid"
    check "$uuid"
  done < devices
  echo sleeping $maxsleeptime seconds
  sleep $maxsleeptime
done

