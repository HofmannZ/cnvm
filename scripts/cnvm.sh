#!/usr/bin/env bash
#
# Provide convenience commands to update and cofigure the cardano-node,
# cardano-cli, and cardano-submit-api binaries.
#
# Copyright 2022 Zino Hofmann
#

#
# Styleguide: https://google.github.io/styleguide/shellguide.html
#

#######################################
# --- GLOBALS ---
#######################################

# Constants
SCRIPT="cnvm"
SCRIPT_VERSION="1.2.0"
REQUIRED_DEPENDENCIES=(curl grep jq lz4 sed tar unzip wget)
DEFAULT_BINARIES_VERSION="1.35.3"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

#######################################
# --- UTILS ---
#######################################

#######################################
# Logs a messages in red.
# Globals:
#   RED
#   NC
# Arguments:
#   Message to log.
#######################################
echo_red() {
  echo -e "${RED}$*${NC}"
}

#######################################
# Logs a messages in green.
# Globals:
#   GREEN
#   NC
# Arguments:
#   Message to log.
#######################################
echo_green() {
  echo -e "${GREEN}$*${NC}"
}

#######################################
# Logs a messages in yellow.
# Globals:
#   YELLOW
#   NC
# Arguments:
#   Message to log.
#######################################
echo_yellow() {
  echo -e "${YELLOW}$*${NC}"
}

#######################################
# Loggs an error messages to STDERR.
# Globals:
#   None
# Arguments:
#   Error message to log.
#######################################
err() {
  echo -e "${RED}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*${NC}" >&2
}

#######################################
# Asserts if the argument has got a value.
# Globals:
#   EOL
# Arguments:
#   Argument name.
#   Maybe argument value.
#######################################
assert_argument() {
  test "$1" != "$EOL" || err "💥 $2 requires an argument."
}

#######################################
# --- PROGRAM ---
#######################################

#######################################
# Prints the version of this script.
# Globals:
#   SCRIPT
#   SCRIPT_VERSION
# Arguments:
#   None
#######################################
version() {
  echo_green "📦 ${SCRIPT} version ${SCRIPT_VERSION}"
}

#######################################
# Prints usage information of this script.
# Globals:
#   SCRIPT
# Arguments:
#   None
#######################################
usage() {
  echo_green ""
  echo_green "📚 Usage: $SCRIPT [options] <command> [arguments]"
  echo_green ""
  echo_green "Command:"
  echo_green "  install-binaries [version]   Installs the cardano-node, cardano-cli, "
  echo_green "                               and cardano-submit-api binaries."
  echo_green "  download-config-files        Downloads and patches the latest cardano config "
  echo_green "                               files."
  echo_green "  download-snapshot            Downloads the latest database snapshot from "
  echo_green "                               csnapshots.io."
  echo_green "  upgrade [version]            Upgrades binaries and downloads the latest "
  echo_green "                               cardano config files."
  echo_green "  upgrade-self                 Upgrades to the latest version of this script."
  echo_green ""
  echo_green "Options:"
  echo_green "  -h | --help                  Prints this usage help."
  echo_green "  -v | --version               Prints the software version."
  echo_green "  --p2p                        Patches cofiguration for P2P topology."
  echo_green "  --topology                   Additionally downloads the default topology."
  echo_green "  --snapshot                   Additionally downloads the db snapshot."
  echo_green "  --restart                    Stops and starts the cardano-node service."
  echo_green ""
}

#######################################
# Prints a warning that the cardano node service should be stoped.
# Globals:
#   None
# Arguments:
#   None
#######################################
print_cardano_node_service_warning() {
  echo_yellow ""
  echo_yellow "--------------------------------------------------------------------------------"
  echo_yellow "Make sure you stoped the cardano-node service! Run:"
  echo_yellow "$ cardano-service stop"
  echo_yellow ""
  echo_yellow "Or run this command with the '--restart' flag to automatically restart the "
  echo_yellow "cardano-node service."
  echo_yellow ""
  echo_yellow "The process will automatically continue in 10 seconds."
  echo_yellow "Press CTL+C to cancel the process now..."
  echo_yellow "--------------------------------------------------------------------------------"
  echo_yellow ""

  # Allow some time for the user to cancel.
  sleep 10
}

#######################################
# Stops the cardano node service
# Globals:
#   None
# Arguments:
#   None
#######################################
stop_cardano_node_service() {
  echo_yellow ""
  echo_yellow "--------------------------------------------------------------------------------"
  echo_yellow "You are about to temporarily stop the cardano-node to "
  echo_yellow "$1."
  echo_yellow "After this is done, the cardano-node will automatically start agian."
  echo_yellow ""
  echo_yellow "The process will automatically continue in 10 seconds."
  echo_yellow "Press CTL+C to cancel the process now..."
  echo_yellow "--------------------------------------------------------------------------------"
  echo_yellow ""

  # Allow some time for the user to cancel.
  sleep 10

  echo_green "🛑 Stopping cardano-node..."
  cardano-service stop
}

#######################################
# Starts the cardano node service
# Globals:
#   None
# Arguments:
#   None
#######################################
start_cardano_node_service() {
  echo_green "🚀 Starting Cardano node..."
  cardano-service start
}

#######################################
# Downloads and installs the cardano-node, cardano-cli, and cardano-submit-api binaries.
# Globals:
#   HOME
#   DEFAULT_BINARIES_VERSION
# Arguments:
#   Binaries version.
#######################################
install_binaries() {
  local binaries_version=$1           # User provided binaries version.
  local binaries_version_for_download # Binaries version written with underscore eg. 1.34.1 -> 1_34_1
  local currrent_dir                  # The current directory.

  echo_green "🧰 Installing Cardano binaries..."

  if [[ -z "$1" ]]; then
    echo_yellow "📋 No version provided, using default version ${DEFAULT_BINARIES_VERSION}."
    binaries_version=$DEFAULT_BINARIES_VERSION
  fi

  # Replace the dots with underscores.
  binaries_version_for_download="${binaries_version//\./_}"

  echo_green "💾 Saving directory..."
  currrent_dir=$(pwd)

  echo_green "📂 Moving to temporary directory..."
  cd "${HOME}/tmp" || exit 1

  echo_green "💽 Downloading the latest binaries..."
  wget -O "cardano-node-${binaries_version_for_download}.zip" "https://github.com/armada-alliance/cardano-node-binaries/blob/main/static-binaries/${binaries_version_for_download}.zip?raw=true" >/dev/null 2>&1
  unzip "cardano-node-${binaries_version_for_download}.zip"

  echo_green "🗄 Moving latest binaries to bin... (type y to overide)"
  mv cardano-node/* "${HOME}/.local/bin"
  rm -r cardano*

  echo_green "✅ Restoring directory..."
  cd "${currrent_dir}" || exit 1
}

#######################################
# Creates the p2p topology file.
# Globals:
#   NODE_CONFIG
# Arguments:
#   None
#######################################
create_p2p_topology() {
  local block_producer_ip
  local block_producer_port

  echo_green "📋 Generating P2P topology..."
  read -e -r -p "What is the Block Producer IP? " block_producer_ip
  read -e -r -p "What is the Block Producer port? " block_producer_port

  echo "{
  \"LocalRoots\": {
    \"groups\": [
      {
        \"localRoots\": {
          \"accessPoints\": [
            {
              \"address\": \"${block_producer_ip}\",
              \"port\": ${block_producer_port}
            }
          ],
          \"advertise\": false
        },
        \"valency\": 1
      }
    ]
  },
  \"PublicRoots\": [
    {
      \"publicRoots\": {
        \"accessPoints\": [
          {
            \"address\": \"relays-new.cardano-${NODE_CONFIG}.iohk.io\",
            \"port\": 3001
          }
        ],
        \"advertise\": true
      },
      \"valency\": 1
    }
  ],
  \"useLedgerAfterSlot\": 0
}" >>"${NODE_CONFIG}-topology.json"
}

#######################################
# Downloads and patches the the latest cardano config files.
# Globals:
#   HOME
#   NODE_FILES
#   NODE_CONFIG
# Arguments:
#   P2P.
#   Download topology.
#######################################
download_config_files() {
  local peer_to_peer=$1      # Whether on not the config should be patched for p2p.
  local download_topology=$2 # Whether on not the config should be patched for p2p.
  local currrent_dir         # The current directory.
  local node_build_num       # The latest cardano-deployment build numbe.

  echo_green "🧰 Downloading the latest config files..."

  echo_green "💾 Saving directory..."
  currrent_dir=$(pwd)

  echo_green "📂 Moving to node files directory..."
  cd "${NODE_FILES}" || exit 1

  echo_green "🔦 Fetching the latest build number..."
  node_build_num=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')

  echo_green "🤕 Patching the build number in .adaenv..."
  sed -i "${HOME}/.adaenv" \
    -e "s/NODE_BUILD_NUM=.*/NODE_BUILD_NUM=${node_build_num}/g"

  # TODO(HofmannZ): add notice to reload other shells to get the latest build number
  echo_green "📡 Sourcing .adaenv..."
  source "${HOME}/.adaenv"

  echo_green "💽 Downloading the latest node files..."
  wget -N "https://hydra.iohk.io/build/${node_build_num}/download/1/${NODE_CONFIG}-config.json" >/dev/null 2>&1
  wget -N "https://hydra.iohk.io/build/${node_build_num}/download/1/${NODE_CONFIG}-byron-genesis.json" >/dev/null 2>&1
  wget -N "https://hydra.iohk.io/build/${node_build_num}/download/1/${NODE_CONFIG}-shelley-genesis.json" >/dev/null 2>&1
  wget -N "https://hydra.iohk.io/build/${node_build_num}/download/1/${NODE_CONFIG}-alonzo-genesis.json" >/dev/null 2>&1
  wget -N https://raw.githubusercontent.com/input-output-hk/cardano-node/master/cardano-submit-api/config/tx-submit-mainnet-config.yaml >/dev/null 2>&1

  if [[ $peer_to_peer == "Enabled" ]]; then
    # Download the default topology file.
    if [[ $download_topology == "Yes" ]]; then
      create_p2p_topology
    fi

    echo_green "🤕 Patching ${NODE_CONFIG}-config.json with P2P support..."
    sed -i "${NODE_CONFIG}-config.json" \
      -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
      -e "s/127.0.0.1/0.0.0.0/g" \
      -e "s+\"TurnOnLogging\": true,+\"TurnOnLogging\": true,\n  \"TestEnableDevelopmentNetworkProtocols\": true,\n  \"EnableP2P\": true,\n  \"MaxConcurrencyBulkSync\": 2,\n  \"MaxConcurrencyDeadline\": 4,\n  \"TargetNumberOfRootPeers\": 50,\n  \"TargetNumberOfKnownPeers\": 50,\n  \"TargetNumberOfEstablishedPeers\": 25,\n  \"TargetNumberOfActivePeers\": 10,+"
  else
    # Download the default topology file.
    if [[ $download_topology == "Yes" ]]; then
      wget -N "https://hydra.iohk.io/build/${node_build_num}/download/1/${NODE_CONFIG}-topology.json" >/dev/null 2>&1
    fi

    echo_green "🤕 Patching ${NODE_CONFIG}-config.json..."
    sed -i "${NODE_CONFIG}-config.json" \
      -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
      -e "s/127.0.0.1/0.0.0.0/g"
  fi

  echo_green "✅ Restoring directory..."
  cd "${currrent_dir}" || exit 1
}

#######################################
# Downloads the latest database snapshot from csnapshots.io.
# Globals:
#   NODE_HOME
#   DB_PATH
# Arguments:
#   None
#######################################
download_db_snapshot() {
  echo_green "🧰 Downloading the latest database snapshot..."

  # echo_yellow ""
  # echo_yellow "--------------------------------------------------------------------------------"
  # echo_yellow "⛔️ You are about to download the latest database snapshot, this process "
  # echo_yellow "will take approximately one hour."
  # echo_yellow ""
  # echo_yellow "Make sure you stoped the cardano-node service! Run:"
  # echo_yellow "$ cardano-service stop"
  # echo_yellow ""
  # echo_yellow "The process will automatically continue in 10 seconds."
  # echo_yellow "Press CTL+C to cancel the process now..."
  # echo_yellow "--------------------------------------------------------------------------------"
  # echo_yellow ""

  echo_green "🗑 Deleting old db..."
  rm -r "${DB_PATH}"

  echo_green "📦 Downloading database snapshot... (this might take more than a hour)"
  curl -o - "https://downloads.csnapshots.io/mainnet/$(curl -s https://downloads.csnapshots.io/mainnet/mainnet-db-snapshot.json | jq -r .[].file_name)" | lz4 -c -d - | tar -x -C "${NODE_HOME}"
}

#######################################
# Upgrades to the latest version of this script.
# Globals:
#   CNVM_HOME
# Arguments:
#   None
#######################################
upgrade_self() {
  local currrent_dir # The current directory.

  echo_green "🧰 Upgrading ${SCRIPT}..."

  echo_green "💾 Saving directory..."
  currrent_dir=$(pwd)

  echo_green "📂 Pulling latest changes..."
  cd "${CNVM_HOME}" || exit 1
  git pull

  echo_green "✅ Restoring directory..."
  cd "${currrent_dir}" || exit 1
}

main() {
  # Check for required dependencies.
  for required_dependency in "${REQUIRED_DEPENDENCIES[@]}"; do
    if ! command -v "$required_dependency" >/dev/null 2>&1; then
      err "💥 Required '${required_dependency}' is not installed."
      exit 1
    fi
  done

  local peer_to_peer="Disabled"
  local download_topology="No"
  local download_snapshot="No"
  local restart_cardano_node="No"

  # Proccess arguments and options.
  # (See: https://stackoverflow.com/a/62616466/6121420)
  if [[ "$#" != 0 ]]; then
    EOL=$(printf '\1\3\3\7')
    set -- "$@" "$EOL"

    while [[ "$1" != "$EOL" ]]; do
      opt="$1"
      shift
      case "$opt" in

      # Options processing.
      -h | --help)
        echo_green "🧰 Convenience commands to update and cofigure the cardano-node, cardano-cli, "
        echo_green "   and cardano-submit-api binaries."
        usage
        exit 0
        ;;
      -v | --version)
        version
        exit 0
        ;;
      --p2p)
        peer_to_peer="Enabled"
        ;;
      --topology)
        download_topology="Yes"
        ;;
      --snapshot)
        download_snapshot="Yes"
        ;;
      --restart)
        restart_cardano_node="Yes"
        ;;
      # -n | --name)
      #   assert_argument "$1" "${opt}"
      #   name="$1"
      #   shift
      #   ;;

      # Arguments processing.
      - | '' | [!-]*) # Positional argument, rotate to the end.
        set -- "$@" "$opt"
        ;;
      --*=*) # Convert '--name=arg' to '--name' 'arg'.
        set -- "${opt%%=*}" "${opt#*=}" "$@"
        ;;
      -[!-]?*) # Convert '-abc' to '-a' '-b' '-c'.
        # shellcheck disable=SC2046,SC2001
        set -- $(echo "${opt#-}" | sed 's/\(.\)/ -\1/g') "$@"
        ;;
      --)
        while [ "$1" != "$EOL" ]; do
          set -- "$@" "$1"
          shift
        done
        ;;
      -*) # Catch misspelled options.
        err "💥 Unknown option: '$opt'"
        usage
        exit 2
        ;;
      *) # Sanity test for previous patterns.
        err "💥 This should NEVER happen ($opt)"
        ;;

      esac
    done
    shift # $EOL
  fi

  case "$1" in
  install-binaries)
    local binaries_version="$2"

    if [[ $restart_cardano_node == "Yes" ]]; then
      stop_cardano_node_service "download the cardano-node binaries"
    else
      print_cardano_node_service_warning
    fi

    install_binaries "$binaries_version"

    if [[ $restart_cardano_node == "Yes" ]]; then
      start_cardano_node_service
    fi
    ;;
  download-config-files)
    download_config_files "$peer_to_peer" "$download_topology"
    ;;
  download-snapshot)

    if [[ $restart_cardano_node == "Yes" ]]; then
      stop_cardano_node_service "download the database snapshot"
    else
      print_cardano_node_service_warning
    fi

    download_db_snapshot

    if [[ $restart_cardano_node == "Yes" ]]; then
      start_cardano_node_service
    fi
    ;;
  upgrade)
    local binaries_version="$2"

    if [[ $restart_cardano_node == "Yes" ]]; then
      stop_cardano_node_service "upgrade the cardano-node"
    else
      print_cardano_node_service_warning
    fi

    install_binaries "$binaries_version"
    download_config_files "$peer_to_peer" "$download_topology"

    if [[ $download_snapshot == "Yes" ]]; then
      download_db_snapshot
    fi

    if [[ $restart_cardano_node == "Yes" ]]; then
      start_cardano_node_service
    fi
    ;;
  upgrade-self)
    upgrade_self
    ;;
  *) # Catch misspelled command.
    err "💥 Unknown command: '$1'"
    usage
    exit 2
    ;;
  esac

  echo_green "✅ All done!"
  exit 0
}

main "$@"
