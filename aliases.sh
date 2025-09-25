# Aliases pour tuer facilement les processus sur le port 3000
# Ajoutez ceci à votre ~/.bashrc ou ~/.zshrc

# Alias simple pour tuer le port 3000
alias kill3000='netstat -tlnp 2>/dev/null | grep :3000 | awk "{print \$7}" | cut -d"/" -f1 | grep -v "-" | sort -u | xargs -r kill -9'

# Alias pour voir les processus sur le port 3000
alias port3000='netstat -tlnp 2>/dev/null | grep :3000'

# Alias pour tuer n'importe quel port (usage: killport 3000)
alias killport='f(){ netstat -tlnp 2>/dev/null | grep ":$1" | awk "{print \$7}" | cut -d"/" -f1 | grep -v "-" | sort -u | xargs -r kill -9; }; f'

# Fonction plus avancée avec confirmation
killport3000() {
    echo "🔍 Recherche des processus sur le port 3000..."
    PIDS=$(netstat -tlnp 2>/dev/null | grep :3000 | awk '{print $7}' | cut -d'/' -f1 | grep -v '-' | sort -u)
    
    if [ -z "$PIDS" ]; then
        echo "✅ Aucun processus trouvé sur le port 3000"
        return 0
    fi
    
    echo "📋 Processus trouvés:"
    netstat -tlnp 2>/dev/null | grep :3000
    
    echo ""
    read -p "❓ Tuer ces processus? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for pid in $PIDS; do
            kill -9 $pid 2>/dev/null && echo "✅ PID $pid tué" || echo "❌ Échec PID $pid"
        done
        echo "✅ Terminé!"
    else
        echo "❌ Annulé"
    fi
}

