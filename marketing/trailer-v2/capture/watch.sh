#!/bin/bash
# usage: watch.sh <log> <display> <size>
d=$2; size=${3:-3840x2160}
tail -n0 -F "$1" 2>/dev/null | while read -r line; do
  case "$line" in
    *"ITCH SHOT "*) name=${line##*SHOT }; ffmpeg -loglevel error -y -f x11grab -draw_mouse 0 -video_size $size -i $d -frames:v 1 "/tmp/trailer/raw2/$name.png" ;;
    *"ITCH REC "*) name=${line##*REC }; (ffmpeg -loglevel error -y -f x11grab -draw_mouse 0 -framerate 30 -video_size $size -i $d -c:v libx264rgb -preset ultrafast -qp 0 "/tmp/trailer/clips2/$name.mkv" < /dev/null & echo $! > /tmp/trailer/rec.pid) ;;
    *"ITCH STOP"*) kill -INT "$(cat /tmp/trailer/rec.pid)" 2>/dev/null ;;
    *"ITCH MOVE "*) xy=${line##*MOVE }; DISPLAY=$d xdotool mousemove $xy ;;
    *"ITCH CLICK "*) xy=${line##*CLICK }; DISPLAY=$d xdotool mousemove $xy click 1 ;;
    *"ITCH KEY "*) k=${line##*KEY }; DISPLAY=$d xdotool key $k ;;
    *"ITCH DONE"*) exit 0 ;;
  esac
done
