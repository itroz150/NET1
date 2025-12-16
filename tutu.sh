#!/bin/bash

# Monte le son
(wpctl set-volume @DEFAULT_SINK@ 1.5 || pactl set-sink-volume @DEFAULT_SINK@ 150%) &>/dev/null

# Désactive Ctrl+C
trap '' INT

# Fait bipper le PC speaker (beeper interne)
play_beep() {
    # Méthode 1: echo vers /dev/console (le plus universel)
    echo -ne '\007' &>/dev/null &
    
    # Méthode 2: printf
    printf '\a' &>/dev/null &
    
    # Méthode 3: beep si disponible
    if command -v beep &>/dev/null; then
        freq=$((100 + RANDOM % 300))
        beep -f $freq -l 50 &>/dev/null &
    fi
}

# Écoute le clavier
xinput test 9 2>/dev/null | while read; do
    play_beep
done
