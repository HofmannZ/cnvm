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

ADAENV_PATH=$1

if (
    [ -z "${ADAENV_PATH}" ]
); then
    ADAENV_PATH=$CARDANO_SPO_TOOLS/.adaenv
fi

echo $(green "💾 Saving config...")
CURRENT_NODE_CONFIG=$NODE_CONFIG
CURRENT_NODE_PORT=$NODE_PORT
CURRENT_NODE_BUILD_NUM=$NODE_BUILD_NUM

echo $(green "📂 Copying .adaenv...")
cp $ADAENV_PATH ~/.adaenv

echo $(green "✅ Restoring config...")
sed -i ~/.adaenv \
    -e "s/NODE_CONFIG=.*/NODE_CONFIG=${CURRENT_NODE_CONFIG}/g" \
    -e "s/NODE_PORT=.*/NODE_PORT=${CURRENT_NODE_PORT}/g" \
    -e "s/NODE_BUILD_NUM=.*/NODE_BUILD_NUM=${CURRENT_NODE_BUILD_NUM}/g"

echo $(green "📡 Sourcing .adaenv...")
source ~/.adaenv
