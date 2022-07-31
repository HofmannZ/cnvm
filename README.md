# Cardano node version manager

Convenience commands for running a Cardano Node.

> These scripts assume you followed the Armada Alliance [environment setup](https://armada-alliance.gitbook.io/welcome/stake-pool-guides/pi-pool-tutorial/pi-node-full-guide/environment-setup).

## 🧰 How to install

```sh
bash <(curl -Ls https://github.com/HofmannZ/cnvm/raw/master/scripts/install.sh)
```

## 📚 How to use

After installing you can use the following commands to manage your Cardano stake pool.

### cnvm

Convenience alias to update your Cardano node binaries.

#### cnvm install-binaries

Installs the cardano-node, cardano-cli, and cardano-submit-api binaries. Version defaults to `1.34.1`, use:

```sh
cnvm install
```

or for a specific version:

```sh
cnvm install 1.35.2
```

or with restart:

```sh
cnvm install --restart
```

#### cnvm download-config-files

Downloads and patches the latest cardano config files. Defaults to normal topology, use:

```sh
cnvm download-config-files
```

or for P2P:

```sh
cnvm download-config-files --p2p
```

> It does **not** override your topology.

#### cnvm download-snapshot

Downloads the latest database snapshot from csnapshots.io. Use:

```sh
cnvm download-snapshot
```

or with restart:

```sh
cnvm download-snapshot --restart
```

> Make use you have stopped you cardano-node! (The script will remind you when you run it.)

#### cnvm upgrade

Upgrades binaries and downloads the latest cardano config files. Optionally downloads the latest snapshot and patches for P2P. Version defaults to `1.34.1`, use:

```sh
cnvm upgrade
```

or for a specific version:

```sh
cnvm upgrade 1.35.2
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
2. Download the latest binaries (defaults to `1.34.1`).
3. Fetch the latest build number and save it to your `.adaenv`.
4. Download the latest node files (with the exception of the topology file).
5. Patches the configuration for P2P. (Optional via `--p2p` flag).
6. Download the latest database snapshot from [csnapshots.io](https://csnapshots.io). (Optional via `--snapshot` flag).
7. Start the cardano-node (Optional via `--restart` flag).

#### cnvm upgrade-self

Upgrades to the latest version of this script. Use:

```sh
cnvm upgrade-self
```

### sysup

Convenience alias to update your system.

> Wil run `sudo apt update && sudo apt upgrade -y` under the hood.
