#!/bin/bash

# Monte le son
(wpctl set-volume @DEFAULT_SINK@ 1.5 || pactl set-sink-volume @DEFAULT_SINK@ 150%) &>/dev/null

# Désactive Ctrl+C
trap '' INT

# BEEP MAXIMUM sans permissions
play_beep() {
    # Multiple bells en parallèle
    for i in {1..10}; do
        printf '\a' &
        echo -ne '\007' &
    done
    
    # Bell vers tty
    echo -ne '\007\007\007\007\007' > /dev/tty 2>/dev/null &
    
    # Bell vers stdout/stderr
    echo -ne '\007\007\007' >&2 &
    
    # Si speaker-test est dispo (souvent pas de perm requises)
    if command -v speaker-test &>/dev/null; then
        freq=$((100 + RANDOM % 1000))
        timeout 0.05 speaker-test -t sine -f $freq 2>/dev/null &
    fi
}

# Écoute les devices 10 et 11
{
    xinput test 10 2>/dev/null | while read; do play_beep; done &
    xinput test 11 2>/dev/null | while read; do play_beep; done &
    wait
}
