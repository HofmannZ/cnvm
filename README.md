# Cardano SPO tools

Convenience commands for running a Cardano Node.

## 🧰 How to install

Clone the repository in the `$HOME/git` folder:

```sh
cd $HOME/git
git clone https://github.com/HofmannZ/cardano-spo-tools.git
cd cardano-spo-tools
```

Then, run the install script:

```sh
. $HOME/git/cardano-spo-tools/scripts/install.sh
```

## 📚 How to use

After installing you will have some aliases available to manage your Cardano stake pool.

### sysup

Convenience alias to update your system.

> Wil run `sudo apt update && sudo apt upgrade -y` under the hood.

### cnvm

Convenience alias to update your Cardano node binaries, it will:

1. Download the latest binaries (defaults to `1.34.1`).
2. Fetch the latest build number and save it to your `.adaenv`.
3. Download the latest node files (with the exception of the topology file).
4. Patches the configuration for P2P.
5. Download the latest database snapshot from [csnapshots.io](https://csnapshots.io).

Install a version of the cardano-node. Defaults to `1.34.1`.

```sh
$ cnvm install [version]
```

Downloads the latest config files. It does **not** override your topology.

```sh
$ cnvm update-config
```

This is the fully automated version of the commands above. it wil stop the node, upgrade the binaries and config, download the latest snapshot, and restart the node.

```sh
$ cnvm upgrade [version]
```

### spoup

Convenience alias to update these scripts, it will:

1. Pull the latest changes from GitHub.
2. Copy the `.adaenv` file to the node home.
3. Source the `.adaenv` file to enable the changes.
