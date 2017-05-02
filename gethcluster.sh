# !/bin/bash
# Usage: bash gethcluster.sh <root> <number_of_nodes> <network_id> <genesis_file> <geth_parameters>

ENODES_FILE="enodes.json"
STATIC_NODES_FILE="static-nodes.json"
FIRST_PORT=31100
FIRST_RPC_PORT=8200
LOCALHOST="127.0.0.1"

root=$1
shift
cant_nodes=$1
shift
network_id=$1
shift
genesis_file=$1
shift

directory=$root/$network_id
mkdir -p $directory/data
mkdir -p $directory/log

if [ ! -f "$directory/$ENODES_FILE"  ]; then 
  echo "[" >> $directory/$ENODES_FILE
  for ((node_id=0;node_id<cant_nodes;++node_id)); do
    echo "== Getting enode for node $node_id ($((node_id+1))/$cant_nodes)"
    eth="geth --datadir $directory/data/$node_id --port $((FIRST_PORT + node_id)) --networkid $network_id"
    cmd="$eth js <(echo 'console.log(admin.nodeInfo.enode); exit();') "
    bash -c "$cmd" 2>/dev/null | grep enode | perl -pe "s/\[\:\:\]/$LOCALHOST/g" | perl -pe "s/^/\"/; s/\s*$/\"/;" | tee >> $directory/$ENODES_FILE
    if ((node_id<cant_nodes-1)); then
      echo "," >> $directory/$ENODES_FILE
    fi
  done
  echo "
]" >> $directory/$ENODES_FILE
fi

for ((node_id=0;node_id<cant_nodes;++node_id)); do
  echo "== Starting node $node_id ($((node_id+1))/$cant_nodes)"
  mkdir -p $directory/data/$node_id
  mkdir -p $directory/log/$node_id
  cp $directory/$ENODES_FILE $directory/data/$node_id/$STATIC_NODES_FILE
  bash gethup.sh $directory $node_id $network_id $genesis_file $((FIRST_PORT + node_id)) $((FIRST_RPC_PORT + node_id)) $*
done