#!/bin/bash
echo "📋 Updating Cardano spo tools..."

echo "💾 Saving current directory..."
CURRRENT_DIR=$(pwd)

echo "📂 Pulling latest changes..."
cd $CARDANO_SPO_TOOLS
git pull
adaenvup

echo "✅ Restoring current directory..."
cd $CURRRENT_DIR

echo "✅ All done!"
