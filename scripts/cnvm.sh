#!/bin/bash

# --------------------
# ------- UTILS ------
# --------------------

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

# --------------------
# ------- SETUP ------
# --------------------

# arguments
COMMAND_NAME=$1

# config
DEFAULT_VERSION="1.34.1"

if [[ "$COMMAND_NAME" != "install" && "$COMMAND_NAME" != "update-config" && "$COMMAND_NAME" != "upgrade" ]]; then
    echo $(red "💥 Incorrect usage of the cnvm command!")
    echo $(yellow "📚 Usage:")
    echo $(yellow "$  cnvm install [version]    # Installs a version of the cardano-node. (default: ")$(green "$DEFAULT_VERSION")$(yellow ").")
    echo $(yellow "$  cnvm update-config        # Downloads the latest config files.")
    echo $(yellow "$  cnvm upgrade [version]    # Updates binaries, downloads configs files and syncs the chain.")
    exit 1
fi

# --------------------
# ---- FUNCTIONS -----
# --------------------

install_fn() {
    echo $(green "🧰 Installing Cardano binaries...")

    # avoid additinal loggs when running as bundled command
    IS_BUNDELD_COMMAND=$1

    if [[ "$IS_BUNDELD_COMMAND" != "true" ]]; then
        # function that will get executed when the user presses Ctrl+C
        function handle_exit() {
            echo $(green "👍 Canceled installation.")
            exit 0
        }

        # assign the handle_exit function to the SIGINT signal
        trap handle_exit SIGINT

        echo ""
        echo $(yellow "-------------------------------------------------------")
        echo $(yellow "Make sure you stoped the cardano-node servie! Run:     ")
        echo $(yellow "$ cardano-service stop                                 ")
        echo ""
        echo $(yellow "The install will automatically continue in 10 seconds. ")
        echo $(yellow "Press CTL+C to cancel the install now...               ")
        echo $(yellow "-------------------------------------------------------")
        echo ""

        # allow the user to cancel
        sleep 10
    fi

    BINARIES_VERSION=$2

    if (
        [ -z "$2" ]
    ); then
        echo $(yellow "📋 No version provided, using default (${DEFAULT_VERSION})")
        BINARIES_VERSION=$DEFAULT_VERSION
    fi

    # replace the dots with underscores
    BINARIES_VERSION_FOR_DOWNLOAD=$(echo "${BINARIES_VERSION//\./_}")

    echo $(green "💾 Saving directory...")
    CURRRENT_DIR=$(pwd)

    echo $(green "📂 Moving to temporary directory...")
    cd $HOME/tmp

    echo $(green "💽 Downloading the latest binaries...")
    wget -O cardano-node-${BINARIES_VERSION_FOR_DOWNLOAD}.zip https://github.com/armada-alliance/cardano-node-binaries/blob/main/static-binaries/${BINARIES_VERSION_FOR_DOWNLOAD}.zip?raw=true >/dev/null 2>&1
    unzip cardano-node-${BINARIES_VERSION_FOR_DOWNLOAD}.zip

    echo $(green "🗄 Moving latest binaries to bin... (type y to overide)")
    mv cardano-node/* ~/.local/bin
    rm -r cardano*

    echo $(green "✅ Restoring directory...")
    cd $CURRRENT_DIR

    if [[ "$IS_BUNDELD_COMMAND" != "true" ]]; then
        echo $(green "✅ All done!")
        exit 0
    fi
}

update_config_fn() {
    echo $(green "🧰 Downloading the latest config files...")

    # avoid additinal loggs when running as bundled command
    IS_BUNDELD_COMMAND=$1

    echo $(green "💾 Saving directory...")
    CURRRENT_DIR=$(pwd)

    echo $(green "📂 Moving to node files directory...")
    cd $NODE_FILES

    echo $(green "🔦 Fetching the latest build number...")
    NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')

    echo $(green "🤕 Patching the build number in .adaenv...")
    sed -i ${HOME}/.adaenv \
        -e "s/NODE_BUILD_NUM=.*/NODE_BUILD_NUM=${NODE_BUILD_NUM}/g"

    echo $(green "📡 Sourcing .adaenv...")
    source ${HOME}/.adaenv

    echo $(green "💽 Downloading the latest node files...")
    wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json >/dev/null 2>&1
    wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json >/dev/null 2>&1
    wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json >/dev/null 2>&1
    wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-alonzo-genesis.json >/dev/null 2>&1
    # wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-topology.json
    wget -N https://raw.githubusercontent.com/input-output-hk/cardano-node/master/cardano-submit-api/config/tx-submit-mainnet-config.yaml >/dev/null 2>&1

    echo $(green "🤕 Patching ${NODE_CONFIG}-config.json with P2P support...")
    sed -i ${NODE_CONFIG}-config.json \
        -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
        -e "s/127.0.0.1/0.0.0.0/g" \
        -e 's+"TurnOnLogging": true,+"TurnOnLogging": true,\n  "TestEnableDevelopmentNetworkProtocols": true,\n  "EnableP2P": true,\n  "MaxConcurrencyBulkSync": 2,\n  "MaxConcurrencyDeadline": 4,\n  "TargetNumberOfRootPeers": 50,\n  "TargetNumberOfKnownPeers": 50,\n  "TargetNumberOfEstablishedPeers": 25,\n  "TargetNumberOfActivePeers": 10,+'

    echo $(green "✅ Restoring directory...")
    cd $CURRRENT_DIR

    if [[ "$IS_BUNDELD_COMMAND" != "true" ]]; then
        echo $(green "✅ All done!")
        exit 0
    fi
}

# --------------------
# ----- COMMANDS -----
# --------------------

if [[ "$COMMAND_NAME" == "install" ]]; then
    install_fn false $2
fi

if [[ "$COMMAND_NAME" == "update-config" ]]; then
    update_config_fn false
fi

if [[ "$COMMAND_NAME" == "upgrade" ]]; then
    echo $(green "🧰 Upgrading Cardano node...")

    # function that will get executed when the user presses Ctrl+C
    function handle_exit() {
        echo $(green "👍 Canceled upgrade.")
        exit 0
    }

    # assign the handle_exit function to the SIGINT signal
    trap handle_exit SIGINT

    echo ""
    echo $(yellow "-------------------------------------------------------")
    echo $(yellow "You are about to upgrade your cardano-node, this       ")
    echo $(yellow "process will stop your cardano-node for approximately  ")
    echo $(yellow "one hour.                                              ")
    echo ""
    echo $(yellow "After the upgrade the cardano-node will automatically  ")
    echo $(yellow "start again.                                           ")
    echo ""
    echo $(yellow "The upgrade will automatically continue in 10 seconds  ")
    echo $(yellow "Press CTL+C to cancel the upgrade now...               ")
    echo $(yellow "-------------------------------------------------------")
    echo ""

    # allow the user to cancel
    sleep 10

    echo $(green "🛑 Stopping Cardano node...")
    cardano-service stop

    install_fn true $2
    update_config_fn true

    echo $(green "🗑 Deleting old db...")
    rm -r $DB_PATH

    echo $(green "📦 Downloading database snapshot... (this might take more than a hour)")
    curl -o - https://downloads.csnapshots.io/mainnet/$(curl -s https://downloads.csnapshots.io/mainnet/mainnet-db-snapshot.json | jq -r .[].file_name) | lz4 -c -d - | tar -x -C $NODE_HOME

    echo $(green "🚀 Starting Cardano node...")
    cardano-service start

    echo $(green "✅ All done!")
    exit 0
fi
