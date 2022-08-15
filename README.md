# Cardano Node Version Manager

Convenience commands for running a Cardano Node.

> These scripts assume you followed the Armada Alliance [environment setup](https://armada-alliance.gitbook.io/welcome/stake-pool-guides/pi-pool-tutorial/pi-node-full-guide/environment-setup).

## 🗄 Table of contents

**[How to install](#how-to-install)**<br>
**[How to use](#how-to-use)**<br>
**└[cnvm](#cnvm)**<br>
** └[install-binaries](#$-cnvm-install-binaries)**<br>
** └[download-config-files](#$-cnvm-download-config-files)**<br>
** └[download-snapshot](#$-cnvm-download-snapshot)**<br>
** └[upgrade](#$-cnvm-upgrade)**<br>
**└[sysup](#sysup)**<br>

## 🧰 How to install

```sh
bash <(curl -Ls https://github.com/HofmannZ/cnvm/raw/master/scripts/install.sh)
```

## 📚 How to use

After installing you can use the following commands to manage your Cardano stake pool.

### cnvm

Convenience alias to update your Cardano node binaries.

#### $ cnvm install-binaries

Installs the cardano-node, cardano-cli, and cardano-submit-api binaries. Version defaults to `1.35.3`, use:

```sh
cnvm install-binaries
```

or for a specific version:

```sh
cnvm install-binaries 1.34.1
```

or with restart:

```sh
cnvm install-binaries --restart
```

#### $ cnvm download-config-files

Downloads and patches the latest cardano config files. Defaults to normal topology, use:

```sh
cnvm download-config-files
```

or for P2P:

```sh
cnvm download-config-files --p2p
```

> CNVM does **not** override your topology by default.

Use with the `--topology` flag to override the topology:

```sh
cnvm download-config-files --topology
```

#### $ cnvm download-snapshot

Downloads the latest database snapshot from csnapshots.io. Use:

```sh
cnvm download-snapshot
```

> Make use you have stopped you cardano-node!

Or use with the `--restart` flag to automatically stop/start:

```sh
cnvm download-snapshot --restart
```

#### $ cnvm upgrade

Upgrades binaries and downloads the latest cardano config files. Optionally downloads the latest snapshot and patches for P2P. Version defaults to `1.35.3`, use:

```sh
cnvm upgrade
```

or for a specific version:

```sh
cnvm upgrade 1.34.1
```

or with snapshot:

```sh
cnvm upgrade --snapshot
```

or with p2p:

```sh
cnvm upgrade --p2p
```

or with restart:

```sh
cnvm upgrade --restart
```

The underlying algorithm:

1. Stop the cardano-node (Optional via `--restart` flag).
2. Download the latest binaries (defaults to `1.35.3`).
3. Fetch the latest build number and save it to your `.adaenv`.
4. Download the latest node files (with the exception of the topology file).
5. Patches the configuration for P2P. (Optional via `--p2p` flag).
6. Download the latest database snapshot from [csnapshots.io](https://csnapshots.io). (Optional via `--snapshot` flag).
7. Start the cardano-node (Optional via `--restart` flag).

#### $ cnvm upgrade-self

Upgrades to the latest version of this script. Use:

```sh
cnvm upgrade-self
```

### sysup

Convenience alias to update your system.

> Wil run `sudo apt update && sudo apt upgrade -y`.
