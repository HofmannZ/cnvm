#!/bin/bash
ADAENV_PATH=$1

if (
    [ -z "${ADAENV_PATH}" ]
); then
    ADAENV_PATH=$CARDANO_SPO_TOOLS/.adaenv
fi

echo "💾 Saving config..."
CURRENT_NODE_CONFIG=$NODE_CONFIG
CURRENT_NODE_PORT=$NODE_PORT

echo "📂 Copying .adaenv..."
cp $ADAENV_PATH ~/.adaenv

echo "✅ Restoring config..."
sed -i ~/.adaenv \
    -e "s/NODE_CONFIG.*/NODE_CONFIG=${CURRENT_NODE_CONFIG}/g" \
    -e "s/NODE_PORT.*/NODE_PORT=${CURRENT_NODE_PORT}/g"

echo "📡 Sourcing .adaenv..."
source ~/.adaenv
