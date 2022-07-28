echo "💾 Saving config..."
CURRENT_NODE_CONFIG=$NODE_CONFIG
CURRENT_NODE_PORT=$NODE_PORT

echo "📂 Copying adaenv..."
cp $CARDANO_SPO_TOOLS/.adaenv ~/.adaenv

echo "✅ Restoring config..."
sed -i ${HOME}/.adaenv \
    -e "s/NODE_CONFIG.*/NODE_CONFIG=${CURRENT_NODE_CONFIG}/g" \
    -e "s/NODE_PORT.*/NODE_PORT=${CURRENT_NODE_PORT}/g"

echo "📂 Sourcing adaenv..."
source ~/.adaenv
