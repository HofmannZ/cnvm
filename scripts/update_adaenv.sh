echo "💾 Saving partial config..."
CURRENT_NODE_CONFIG=$NODE_CONFIG
CURRENT_NODE_PORT=$NODE_PORT

echo "📂 Copying adaenv..."
cp $DOTFILES/.adaenv ~/.adaenv

echo "✅ Restoring partial config..."
sed -i ${HOME}/.adaenv \
    -e "s/NODE_CONFIG.*/NODE_CONFIG=${CURRENT_NODE_CONFIG}/g" \
    -e "s/NODE_PORT.*/NODE_PORT=${CURRENT_NODE_PORT}/g"

echo "📂 Sourcing adaenv..."
source ~/.adaenv
