#!/bin/bash
# Script pour analyser ET nettoyer l'espace dans AFS

echo "=== Quota AFS actuel ==="
fs quota
QUOTA_AVANT=$(fs quota | grep -oP '\d+(?=% of quota used)')

echo -e "\n=== Utilisation par répertoire (top 20) ==="
du -sh ~/* ~/.[^.]* 2>/dev/null | sort -hr | head -20

echo -e "\n=========================================="
echo "  NETTOYAGE AUTOMATIQUE EN COURS"
echo "=========================================="

ESPACE_LIBERE=0

# Nettoyage des caches courants
echo -e "\n[1/6] Nettoyage des caches..."
if [ -d ~/.cache ]; then
    TAILLE=$(du -sb ~/.cache 2>/dev/null | cut -f1)
    rm -rf ~/.cache/* 2>/dev/null
    echo "  ✓ Cache utilisateur nettoyé ($(numfmt --to=iec $TAILLE 2>/dev/null || echo $TAILLE))"
    ESPACE_LIBERE=$((ESPACE_LIBERE + TAILLE))
fi

if [ -d ~/.npm ]; then
    TAILLE=$(du -sb ~/.npm 2>/dev/null | cut -f1)
    rm -rf ~/.npm/* 2>/dev/null
    echo "  ✓ Cache npm nettoyé ($(numfmt --to=iec $TAILLE 2>/dev/null || echo $TAILLE))"
    ESPACE_LIBERE=$((ESPACE_LIBERE + TAILLE))
fi

# Nettoyage des fichiers temporaires
echo -e "\n[2/6] Suppression des fichiers temporaires..."
COUNT=$(find ~ -name "*.tmp" -o -name "*.temp" 2>/dev/null | wc -l)
find ~ \( -name "*.tmp" -o -name "*.temp" \) -delete 2>/dev/null
echo "  ✓ $COUNT fichiers .tmp/.temp supprimés"

# Nettoyage des vieux logs
echo -e "\n[3/6] Suppression des fichiers log de plus de 30 jours..."
COUNT=$(find ~ -name "*.log" -mtime +30 2>/dev/null | wc -l)
find ~ -name "*.log" -mtime +30 -delete 2>/dev/null
echo "  ✓ $COUNT vieux fichiers .log supprimés"

# Nettoyage des sauvegardes
echo -e "\n[4/6] Suppression des fichiers de sauvegarde..."
COUNT=$(find ~ \( -name "*.bak" -o -name "*.backup" -o -name "*~" \) 2>/dev/null | wc -l)
find ~ \( -name "*.bak" -o -name "*.backup" -o -name "*~" \) -delete 2>/dev/null
echo "  ✓ $COUNT fichiers de sauvegarde supprimés"

# Nettoyage corbeille
echo -e "\n[5/6] Vidage de la corbeille..."
if [ -d ~/.local/share/Trash ]; then
    rm -rf ~/.local/share/Trash/* 2>/dev/null
    echo "  ✓ Corbeille vidée"
fi

# Nettoyage fichiers core dump
echo -e "\n[6/6] Suppression des core dumps..."
COUNT=$(find ~ -name "core.*" -o -name "core" 2>/dev/null | wc -l)
find ~ \( -name "core.*" -o -name "core" \) -type f -delete 2>/dev/null
echo "  ✓ $COUNT fichiers core supprimés"

echo -e "\n=========================================="
echo "  RÉSUMÉ"
echo "=========================================="
fs quota
QUOTA_APRES=$(fs quota | grep -oP '\d+(?=% of quota used)')
echo -e "\nQuota avant : ${QUOTA_AVANT}%"
echo "Quota après : ${QUOTA_APRES}%"
echo "Gain : $((QUOTA_AVANT - QUOTA_APRES))%"

echo -e "\n=== Fichiers volumineux restants (>100MB) ==="
find ~ -type f -size +100M -exec du -h {} + 2>/dev/null | sort -hr | head -10
