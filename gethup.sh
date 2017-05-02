# !/bin/bash
# Usage: bash gethup.sh <root> <node_id> <network_id> <genesis_file> <port> <rpc_port> <geth_parameters>

root=$1
shift
node_id=$1
shift
network_id=$1
shift
genesis_file=$1
shift
port=$1
shift
rpc_port=$1
shift

date_tag=$(date +%Y-%m-%d' '%H:%M:%S)

data_directory=$root/data/$node_id       
log_directory=$root/log/$node_id    
mkdir -p $data_directory
mkdir -p $log_directory

log_file=$log_directory/$date_tag.log     
link_log_file=$log_directory/current.log    
stable_log_file=$log_directory/stable.log   
ln -sf "$log_file" "$link_log_file"

password=$node_id

if [ ! -d "$root/keystore/$node_id" ]; then
  echo "==== Initializing node with genesis blockchain file"
  geth --datadir $data_directory init $genesis_file
    
  echo "==== Creating an account with password $node_id [NEVER USE THIS LIVE]"
  mkdir -p $root/keystore/$node_id
  geth --datadir $data_directory --password <(echo -n $node_id) account new 
  cp -R "$data_directory/keystore" $root/keystore/$node_id
fi

cp -R $root/keystore/$node_id/keystore/ $data_directory/keystore/

key=$(geth --datadir $data_directory account list | head -n1 | perl -ne '/([a-f0-9]{40})/ && print $1')

echo "==== Launching"
echo "geth --datadir $data_directory \
  --identity $node_id \
  --networkid $network_id \
  --port $port \
  --unlock $key \
  --password <(echo -n $node_id) \
  --nodiscover \
  --rpc \
  --rpcport $rpc_port \
  --rpccorsdomain '*' $*"
geth --datadir $data_directory \
  --identity $node_id \
  --networkid $network_id \
  --port $port \
  --unlock $key \
  --password <(echo -n $node_id) \
  --nodiscover \
  --rpc \
  --rpcport $rpc_port \
  --rpccorsdomain '*' $* \
  2>&1 | tee "$stable_log_file" > "$log_file" &