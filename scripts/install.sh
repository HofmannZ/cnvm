#!/bin/bash
echo "📦 Installing dependencies..."
sudo apt update && sudo apt install liblz4-tool jq curl -y

. $HOME/git/cardano-spo-tools/scripts/update_adaenv.sh $HOME/git/cardano-spo-tools/.adaenv
