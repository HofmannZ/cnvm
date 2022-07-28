#!/bin/bash
CARDANO_NODE_BINARIES_VERSION=$1

if (
    [ -z "${CARDANO_NODE_BINARIES_VERSION}" ]
); then
    CARDANO_NODE_BINARIES_VERSION=1_34_1
    echo "📋 Using default version ${CARDANO_NODE_BINARIES_VERSION}"
fi

echo "💾 Saving current directory..."
CURRRENT_DIR=$(pwd)

cd

echo "💽 Downloading the latest binaries..."
wget -O cardano-node-${CARDANO_NODE_BINARIES_VERSION}.zip https://github.com/armada-alliance/cardano-node-binaries/blob/main/static-binaries/${CARDANO_NODE_BINARIES_VERSION}.zip?raw=true
unzip cardano-node-${CARDANO_NODE_BINARIES_VERSION}.zip

cardano-service status
cardano-service stop

mv cardano-node/* ~/.local/bin
rm -r cardano*

echo "🧮 Fetching the latest build number..."
NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')

sed -i ${HOME}/.adaenv \
    -e "s/NODE_BUILD_NUM.*/NODE_BUILD_NUM=${NODE_BUILD_NUM}/g"

source ${HOME}/.adaenv

echo "📂 Downloading the latest node files..."
cd $NODE_FILES
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-alonzo-genesis.json
# wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-topology.json
wget -N https://raw.githubusercontent.com/input-output-hk/cardano-node/master/cardano-submit-api/config/tx-submit-mainnet-config.yaml

sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
    -e "s/127.0.0.1/0.0.0.0/g" \
    -e 's+"TurnOnLogging": true,+"TurnOnLogging": true,\n  "TestEnableDevelopmentNetworkProtocols": true,\n  "EnableP2P": true,\n  "MaxConcurrencyBulkSync": 2,\n  "MaxConcurrencyDeadline": 4,\n  "TargetNumberOfRootPeers": 50,\n  "TargetNumberOfKnownPeers": 50,\n  "TargetNumberOfEstablishedPeers": 25,\n  "TargetNumberOfActivePeers": 10,+'

echo "✅ Restoring current directory..."
cd $CURRRENT_DIR

echo "🗂 Downloading database snapshot..."
curl -o - https://downloads.csnapshots.io/mainnet/$(curl -s https://downloads.csnapshots.io/mainnet/mainnet-db-snapshot.json | jq -r .[].file_name) | lz4 -c -d - | tar -x -C $NODE_HOME

echo "🚀 Restarting Cardano node..."
cardano-service start

echo "✅ All done!"
