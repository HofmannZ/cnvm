#!/bin/bash
echo "📦 Installing dependencies..."
sudo apt update && sudo apt install liblz4-tool jq git -y

echo "💾 Saving directory..."
CURRRENT_DIR=$(pwd)

echo "📂 Cloning repository..."
cd $HOME/git
git clone https://github.com/HofmannZ/cardano-spo-tools.git

echo "✅ Restoring directory..."
cd $CURRRENT_DIR

. $HOME/git/cardano-spo-tools/scripts/update_adaenv.sh $HOME/git/cardano-spo-tools/.adaenv

echo "✅ All done!"
