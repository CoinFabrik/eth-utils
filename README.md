## eth-utils

Ethereum utilities, dev tools, scripts, etc.

- `gethup.sh`: primitive wrapper for [geth](https://github.com/ethereum/go-ethereum)
- `gethcluster.sh`: launch [local clusters](https://github.com/ethereum/go-ethereum/wiki/Setting-up-private-network-or-local-cluster) non-interactively
- `netstatconf.sh`: auto-generate the JSON config of your local cluster for netstat (https://github.com/ethereum/go-ethereum/wiki/Setting-up-monitoring-on-local-cluster)

##  Usage

### Launch an instance

```
bash /path/to/eth-utils/gethup.sh <root> <id> <network_id> <genesis_file> <port> <rpc_port> <geth_parameters>
```

This will:
- if its the first launch it will initialize the node with `<genesis_file>`,
- if it does not exist yet, then create an account with password `<id>` (**never use this live**),
- bring up a node
	- using `<root>/<id>` as data directory (where blockchain etc. are stored),
	- with instance id `<id>`,
	- with networkid `<network_id>`,
	- using `<genesis_file>` to initialize the node's blockchain file,
	- listening on port `<port>`,
	- with a JSON-RPC server on port `<rpc_port>`
	- with the parameters determined on `<geth_parameters>`,
	- with the account unlocked and
	- with peer discovery mechanism disabled, and
- save logs on `<root>/logs/<id>/<date>.log`.

### Launch a cluster 

```
bash /path/to/eth-utils/gethcluster.sh <root> <number_of_nodes> <network_id> <genesis_file> <ip> <geth_parameters>
```

This will set up a local cluster of nodes
- with `<root>` as the root directory where the cluster's nodes are set up, 
- with `<number_of_nodes>` nodes,
- with `<network_id>` as networkid,
- using `<genesis_file>` to initialize very node's blockchain file,
- collecting the nodes's enodes so they get connected to each other resulting in a private isolated network (it will use `<ip>` to construct the enode URL, as explained [here](https://github.com/ethereum/go-ethereum/wiki/Setting-up-private-network-or-local-cluster)),
- with the parameters determined on `<geth_parameters>`,
- listening on ports `31101`, `31102`, ..., and `31100 + <number_of_nodes>`, and
- with JSON-RPC servers on ports `8100`, `8101`, ..., `8100 + <number_of_nodes>`.

The cluster can be killed with `killall -QUIT geth`. Using the `-QUIT` signal dumps a stacktrace into each node's log file.

### Monitor your local cluster:

#### Installing the eth-netstats monitor

```
git clone https://github.com/cubedro/eth-netstats
cd eth-netstats
npm install
```

#### Configuring netstat for your cluster

```
bash /path/to/eth-utils/netstatconf.sh <number_of_clusters> <name_prefix> <ws_server> <ws_secret> 
```

- will output resulting app.json to stdout
- `number_of_clusters` is the number of nodes in the cluster.
- `name_prefix` is a prefix for the node names as will appear in the listing.
- `ws_server` is the eth-netstats server. Make sure you write the full URL, for example: http://localhost:3000.
- `ws_secret` is the eth-netstats secret.

For example:

```
git clone https://github.com/ethersphere/eth-utils
cd eth-utils
bash ./netstatconfig.sh 8 cicada http://localhost:3301 kscc > ~/leagues/3301/cicada.json
```

#### Installing eth-net-intelligence-api

```
git clone https://github.com/cubedro/eth-net-intelligence-api
cd eth-net-intelligence-api
npm install
sudo npm install -g pm2
```

#### Starting the eth-net-intelligence-api

to start the eth-net-intelligence-api client for your cluster

```
cd eth-net-intelligence-api
pm2 start ~/leagues/3301/cicada.json
[PM2] Process launched
[PM2] Process launched
┌──────────┬────┬──────┬───────┬────────┬─────────┬────────┬─────────────┬──────────┐
│ App name │ id │ mode │ pid   │ status │ restart │ uptime │ memory      │ watching │
├──────────┼────┼──────┼───────┼────────┼─────────┼────────┼─────────────┼──────────┤
│ cicada-0 │ 1  │ fork │ 93855 │ online │ 0       │ 0s     │ 10.289 MB   │ disabled │
│ cicada-1 │ 2  │ fork │ 93858 │ online │ 0       │ 0s     │ 10.563 MB   │ disabled │
└──────────┴────┴──────┴───────┴────────┴─────────┴────────┴─────────────┴──────────┘
 Use `pm2 show <id|name>` to get more details about an app
```

#### Starting the monitor 

Use your own eth-netstat server to monitor a league on a port corresponding to a league

```
cd eth-netstat
PORT=3301 WS_SECRET=kscc npm start &
```

and enjoy:
```
open http://localhost:3301
```