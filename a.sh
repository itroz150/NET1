#!/bin/bash

# Monte le son
(wpctl set-volume @DEFAULT_SINK@ 1.5 || pactl set-sink-volume @DEFAULT_SINK@ 150%) &>/dev/null

# Désactive Ctrl+C
trap '' INT

# BEEP MAXIMUM sans sudo
play_beep() {
    # Fréquences inquiétantes (très graves ou très aigües)
    freqs=(50 80 100 150 800 1000 1500 2000 3000)
    freq=${freqs[RANDOM % ${#freqs[@]}]}
    duration=$((100 + RANDOM % 200))
    
    # Méthode 1: beep répété (le plus efficace sans sudo)
    if command -v beep &>/dev/null; then
        beep -f $freq -l $duration -r 3 -D 30 &>/dev/null &
    fi
    
    # Méthode 2: Triple bell vers stdout/stderr/console
    echo -ne '\007\007\007' &
    printf '\a\a\a' &
    echo -ne '\007\007\007' >&2 &
    
    # Méthode 3: bell vers tty actuel
    echo -ne '\007\007\007' > /dev/tty 2>/dev/null &
    
    # Méthode 4: Multiples instances en parallèle
    for i in {1..5}; do
        printf '\a' &
    done
}

# Écoute le clavier
xinput test 9 2>/dev/null | while read; do
    play_beep
done
