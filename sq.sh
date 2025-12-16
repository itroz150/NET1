#!/bin/bash

echo "🔍 === DEBUG MODE ==="

# Teste wpctl
echo "Test volume..."
wpctl set-volume @DEFAULT_SINK@ 1.5
if [ $? -eq 0 ]; then
    echo "✅ Volume OK"
else
    echo "❌ Volume FAIL"
fi

# Trouve le périphérique
echo -e "\n📱 Périphériques disponibles:"
xinput list

DEVICE_ID=$(xinput list | grep -i "pointer\|keyboard" | grep -i "slave" | head -1 | sed 's/.*id=\([0-9]*\).*/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Aucun périphérique trouvé, utilisation de 9"
    DEVICE_ID=9
else
    echo "✅ Périphérique trouvé: ID=$DEVICE_ID"
fi

# Teste xinput
echo -e "\n🖱️  Test xinput (bouge ta souris/clavier)..."
echo "Appuie sur Ctrl+C après 5 secondes si tu vois des événements"
timeout 5 xinput test "$DEVICE_ID" | head -5

if [ $? -eq 124 ]; then
    echo "✅ xinput fonctionne!"
else
    echo "❌ xinput ne capte rien"
fi

# Teste pgrep firefox
echo -e "\n🦊 Test Firefox:"
if pgrep -x firefox >/dev/null 2>&1; then
    echo "✅ Firefox détecté (en cours)"
else
    echo "❌ Firefox non détecté (normal si pas lancé)"
fi

# Teste la commande firefox
echo -e "\n🔧 Test commande firefox:"
which firefox
if [ $? -eq 0 ]; then
    echo "✅ Firefox trouvé"
else
    echo "❌ Firefox pas dans le PATH"
fi

echo -e "\n=== FIN DEBUG ==="
echo -e "\nMaintenant teste la boucle (Ctrl+C pour arrêter):"

# Boucle de test visible
xinput test "$DEVICE_ID" | while read -r line; do
    echo "📡 Événement détecté: $line"
    
    if ! pgrep -x firefox >/dev/null 2>&1; then
        echo "🚀 Lancement Firefox..."
        firefox --new-window "https://example.com" &
        sleep 2
    else
        echo "⏭️  Firefox déjà lancé"
    fi
done
