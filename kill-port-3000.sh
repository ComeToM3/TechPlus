#!/bin/bash

# Script pour tuer facilement les processus sur le port 3000
# Usage: ./kill-port-3000.sh

echo "🔍 Recherche des processus sur le port 3000..."

# Trouver les processus sur le port 3000
PIDS=$(netstat -tlnp 2>/dev/null | grep :3000 | awk '{print $7}' | cut -d'/' -f1 | grep -v '-' | sort -u)

if [ -z "$PIDS" ]; then
    echo "✅ Aucun processus trouvé sur le port 3000"
    exit 0
fi

echo "📋 Processus trouvés sur le port 3000:"
netstat -tlnp 2>/dev/null | grep :3000

echo ""
echo "⚠️  Ces processus vont être tués:"
for pid in $PIDS; do
    echo "  - PID: $pid ($(ps -p $pid -o comm= 2>/dev/null || echo 'Processus inconnu'))"
done

echo ""
read -p "❓ Voulez-vous continuer? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "💀 Suppression des processus..."
    
    # Tuer les processus
    for pid in $PIDS; do
        if kill -9 $pid 2>/dev/null; then
            echo "  ✅ PID $pid tué avec succès"
        else
            echo "  ❌ Échec pour tuer le PID $pid"
        fi
    done
    
    # Vérifier que le port est libre
    sleep 1
    if netstat -tlnp 2>/dev/null | grep -q :3000; then
        echo "⚠️  Le port 3000 est encore occupé"
    else
        echo "✅ Le port 3000 est maintenant libre!"
    fi
else
    echo "❌ Opération annulée"
fi
