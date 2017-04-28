# !/bin/bash
# Usage: bash gethcluster.sh <root> <number_of_nodes> <network_id> <genesis_file> <ip> <geth_parameters>

ENODES_FILE="enodes.json"
STATIC_NODES_FILE="static-nodes.json"
FIRST_PORT=31100
FIRST_RPC_PORT=8200

root=$1
shift
cant_nodes=$1
shift
network_id=$1
shift
genesis_file=$1
shift
ip=$1
shift

directory=$root/$network_id
mkdir -p $directory/data
mkdir -p $directory/log

if [ ! -f "$directory/$ENODES_FILE"  ]; then 
  echo "[" >> $directory/$ENODES_FILE
  for ((id=0;id<cant_nodes;++id)); do
    echo "== Getting enode for node $id ($((id+1))/$cant_nodes)"
    eth="geth --datadir $directory/data/$id --port $((FIRST_PORT + id)) --networkid $network_id"
    cmd="$eth js <(echo 'console.log(admin.nodeInfo.enode); exit();') "
    bash -c "$cmd" 2>/dev/null | grep enode | perl -pe "s/\[\:\:\]/$ip/g" | perl -pe "s/^/\"/; s/\s*$/\"/;" | tee >> $directory/$ENODES_FILE
    if ((id<cant_nodes-1)); then
      echo "," >> $directory/$ENODES_FILE
    fi
  done
  echo "
]" >> $directory/$ENODES_FILE
fi

for ((id=0;id<cant_nodes;++id)); do
  echo "== Starting node $id ($((id+1))/$cant_nodes)"
  mkdir -p $directory/data/$id
  mkdir -p $directory/log/$id
  cp $directory/$ENODES_FILE $directory/data/$id/$STATIC_NODES_FILE
  bash gethup.sh $directory $id $network_id $genesis_file $((FIRST_PORT + id)) $((FIRST_RPC_PORT + id)) $*
done