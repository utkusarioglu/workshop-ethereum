#!/bin/bash

source /opt/venv/mythril/bin/activate

# Notice that this code EXPECTS the file name and the contract name
# to be the same. If you have a file named A.sol containing a contract
# B, then jq will return `null` for its bytecode and the contract
# will not be scanned
CONTRACTS=$(jq -r '.sources | keys[] | gsub(".sol";"")' solc.json)
for CONTRACT in $CONTRACTS;
do 
  FILE="$CONTRACT.sol"
  BYTECODE=$(\
    solc --standard-json solc.json --allow-paths $(pwd) | \
    jq -r '.contracts["'$FILE'"].'$CONTRACT'.evm.bytecode.object')
  if [ $BYTECODE != "null" ]
  then 
    echo "Analyzing $CONTRACT..."
    myth analyze -c $BYTECODE
  fi
done
