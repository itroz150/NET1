#!/bin/bash

# Monte le son (silencieux)
(wpctl set-volume @DEFAULT_SINK@ 1.5 || pactl set-sink-volume @DEFAULT_SINK@ 150%) &>/dev/null
sleep 0.5

# Désactive Ctrl+C
trap '' INT

# Joue un son directement depuis YouTube
play_sound() {
    sounds=(
        "ytsearch1:fart sound effect"
        "ytsearch1:wet fart sound"
        "ytsearch1:bubble pop sound effect"
        "ytsearch1:water bubbles sound"
        "ytsearch1:loud fart"
        "ytsearch1:cartoon fart"
    )
    
    random_search="${sounds[RANDOM % ${#sounds[@]}]}"
    
    # Joue directement avec mpv, ffplay ou vlc
    if command -v mpv &>/dev/null; then
        mpv --no-video --volume=100 --really-quiet "ytdl://$random_search" &>/dev/null &
    elif command -v ffplay &>/dev/null; then
        ffplay -nodisp -autoexit -loglevel quiet "$(yt-dlp -g --format bestaudio "$random_search" 2>/dev/null)" &>/dev/null &
    elif command -v cvlc &>/dev/null; then
        cvlc --play-and-exit --no-video "$(yt-dlp -g --format bestaudio "$random_search" 2>/dev/null)" &>/dev/null &
    fi
}

# Vérifie si au moins un player est installé
if ! command -v mpv &>/dev/null && ! command -v ffplay &>/dev/null && ! command -v cvlc &>/dev/null; then
    exit 1
fi

# Écoute le clavier (device 9, adapte si nécessaire)
xinput test 9 2>/dev/null | while read; do
    play_sound
done
