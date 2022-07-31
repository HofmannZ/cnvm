#!/usr/bin/env bash
#
# Install cnvm.

#######################################
# --- GLOBALS ---
#######################################

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
    echo "${RED}$*${NC}"
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
    echo "${GREEN}$*${NC}"
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
    echo "${YELLOW}$*${NC}"
}

#######################################
# Loggs an error messages to STDERR.
# Globals:
#   None
# Arguments:
#   Error message to log.
#######################################
err() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: ${RED}$*${NC}" >&2
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

echo_green "🧰 Installing cnvm..."

echo_green "📦 Installing dependencies..."
sudo apt update && sudo apt install curl grep jq liblz4-tool sed tar unzip wget -y

echo_green "💾 Saving directory..."
currrent_dir=$(pwd)

echo_green "📂 Cloning repository..."
cd "${HOME}/git" || exit 1
git clone https://github.com/HofmannZ/cardano-spo-tools.git

echo_green "📋 Appending config to .adaenv..."
echo '
# config for https://github.com/HofmannZ/cardano-spo-tools
export GIT_HOME=${HOME}/git
export CARDANO_SPO_TOOLS=${GIT_HOME}/cardano-spo-tools

cnvm() {
  "${CARDANO_SPO_TOOLS}/scripts/cnvm.sh" "$@"
}

source "${CARDANO_SPO_TOOLS}/bash/aliases.sh"' >>"${HOME}/.adaenv"

echo_green "📡 Sourcing .adaenv..."
source "${HOME}/.adaenv"

echo_green "✅ Restoring directory..."
cd "${currrent_dir}" || exit 1

echo_green "✅ All done!"
