#!/bin/bash
alias sysup='echo "📋 Updating system packages..." && sudo apt update && sudo apt upgrade -y'
alias nodeup='. ~/git/cardano-spo-tools/scripts/update_binaries.sh'
alias spoup='. ~/git/cardano-spo-tools/scripts/update_self.sh'

alias cnvm='_cnvm() { ~/git/cardano-spo-tools/scripts/cnvm.sh $@; }; _cnvm'
