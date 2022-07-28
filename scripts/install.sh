#!/bin/bash

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

red() {
    printf "${RED}$@${NC}\n"
}
green() {
    printf "${GREEN}$@${NC}\n"
}
yellow() {
    printf "${YELLOW}$@${NC}\n"
}

echo $(green "📦 Installing dependencies...")
sudo apt update && sudo apt install liblz4-tool jq git -y

echo $(green "💾 Saving directory...")
CURRRENT_DIR=$(pwd)

echo $(green "📂 Cloning repository...")
cd $HOME/git
git clone https://github.com/HofmannZ/cardano-spo-tools.git

echo $(green "✅ Restoring directory...")
cd $CURRRENT_DIR

. $HOME/git/cardano-spo-tools/scripts/update_adaenv.sh $HOME/git/cardano-spo-tools/.adaenv

echo $(green "✅ All done!")
