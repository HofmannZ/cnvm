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

echo $(green "📋 Updating Cardano spo tools...")

echo $(green "💾 Saving directory...")
CURRRENT_DIR=$(pwd)

echo $(green "📂 Pulling latest changes...")
cd $CARDANO_SPO_TOOLS
git pull
. ./scripts/update_adaenv.sh

echo $(green "✅ Restoring directory...")
cd $CURRRENT_DIR

echo $(green "✅ All done!")
