#!/bin/bash

# Monte le son (silencieux)
(wpctl set-volume @DEFAULT_SINK@ 1.5 || pactl set-sink-volume @DEFAULT_SINK@ 150%) &>/dev/null
sleep 0.5

# Désactive Ctrl+C
trap '' INT

# Répertoire temporaire pour les sons
SOUND_DIR="/tmp/confluzz_sounds"
mkdir -p "$SOUND_DIR" 2>/dev/null

# Télécharge des sons de pets et bulles depuis YouTube
download_sounds() {
    # Pets
    yt-dlp -x --audio-format wav -o "$SOUND_DIR/fart1.wav" "https://www.youtube.com/watch?v=GW_bGW38T5M" &>/dev/null &
    
    # Bulles
    yt-dlp -x --audio-format wav -o "$SOUND_DIR/bubble1.wav" "https://www.youtube.com/watch?v=cEkKmY95HM0" &>/dev/null &
    
    wait
}

# Vérifie si yt-dlp est installé (silencieusement)
if ! command -v yt-dlp &>/dev/null; then
    exit 1
fi

# Télécharge les sons si pas déjà présents (en arrière-plan silencieux)
if [ ! -f "$SOUND_DIR/fart1.wav" ] || [ ! -f "$SOUND_DIR/bubble1.wav" ]; then
    download_sounds &
fi

# Joue un son aléatoire
play_sound() {
    sounds=("$SOUND_DIR"/*)
    if [ ${#sounds[@]} -gt 0 ]; then
        random_sound="${sounds[RANDOM % ${#sounds[@]}]}"
        if command -v paplay &>/dev/null; then
            paplay "$random_sound" &>/dev/null &
        elif command -v aplay &>/dev/null; then
            aplay -q "$random_sound" &>/dev/null &
        fi
    fi
}

# Écoute le clavier (device 9, adapte si nécessaire)
xinput test 9 2>/dev/null | while read; do
    play_sound
done
