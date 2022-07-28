#!/bin/bash
COMMAND_NAME=$1

if (
    [ -z "${COMMAND_NAME}" ]
); then
    echo ""
    echo "Usage:"
    echo "$ cnvm install <version>                      # Installs a specific version of the cardano-node."
    echo "$ cnvm update config                          # Downloads the latest config files."
    exit 1
fi

if ! [[ "$COMMAND_NAME" =~ ^(install|update)$ ]]; then
    echo "true"
fi

echo "false"
