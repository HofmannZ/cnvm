#!/bin/bash
echo "📋 Updating Cardano spo tools..."

echo "💾 Saving directory..."
CURRRENT_DIR=$(pwd)

echo "📂 Pulling latest changes..."
cd $CARDANO_SPO_TOOLS
git pull
. ./scripts/update_adaenv.sh

echo "✅ Restoring directory..."
cd $CURRRENT_DIR

echo "✅ All done!"
