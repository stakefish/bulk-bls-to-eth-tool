#!/bin/bash

# Parse command-line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --depositor-address)
        depositor="$2"
        shift
        shift
        ;;
        --mnemonic)
        mnemonic="$2"
        shift
        shift
        ;;
        --chain)
        chain="$2"
        shift
        shift
        ;;
        --execution-address)
        execution_address="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown argument: $1"
        exit 1
        ;;
    esac
done

# Use environment variables if command line arguments are not defined
depositor="${depositor:-$DEPOSITOR_ADDRESS}"
mnemonic="${mnemonic:-$MNEMONIC}"
chain="${chain:-$CHAIN}"
execution_address="${execution_address:-$EXECUTION_ADDRESS}"

# Verify execution address
if [ "$execution_address" == "0x0000000000000000000000000000000000000000" ]; then
    echo "Error: Execution address must be set and cannot be null address (0x0000000000000000000000000000000000000000)."
    echo "Please set the EXECUTION_ADDRESS environment variable to a valid Ethereum address."
    echo "Exiting..."
    exit 1
fi

# Verify supported chains
if [ "$chain" = "goerli" ]; then
    url="https://fee-pool-api-goerli.oracle.ethereum.fish/validators?limit=9000&rewards_recipient=$depositor"
elif [ "$chain" = "mainnet" ]; then
    url="https://fee-pool-api-mainnet.prod.ethereum.fish/validators?limit=9000&rewards_recipient=$depositor"
else
    echo "Unknown chain: $chain"
    exit 1
fi

# Download the JSON file
json=$(curl -s "$url")

# Filter the validator indexes with withdrawal_credentials starting with "0x00"
indexes=$(echo $json | jq -r '.results[] | select(.withdrawal_credentials != null and (.withdrawal_credentials | startswith("0x00"))) | .index')

echo "Generating new withdrawal credentials for validators deposited by $depositor..."
echo ""
# Loop through the filtered validator indexes and call the deposit command for each one
for index in $indexes; do
    bls_withdrawal_credentials=$(echo $json | jq -r ".results[] | select(.index == $index) | .withdrawal_credentials")
    deposit_output=$(deposit --non_interactive --language=english generate-bls-to-execution-change --chain="$chain" --mnemonic="$mnemonic" --bls_withdrawal_credentials_list="$bls_withdrawal_credentials" --validator_start_index=0 --validator_indices="$index" --execution_address="$execution_address" 2>&1)
    if [[ "$deposit_output" == *"Success!"* ]]; then
        echo "[OK] Validator #$index with withdrawal credentials $bls_withdrawal_credentials"
    else
        echo "[ERROR] Validator #$index with withdrawal credentials $bls_withdrawal_credentials: please try a different mnemonic."
    fi    
done

echo ""
echo ""
echo "Uploading files with new BLS credentials to Beacon Chain..."
echo ""

# Loop through all files in /app/bls_to_execution_changes directory and execute curl command
for file in /app/bls_to_execution_changes/*; do
    if [ -f "$file" ]; then
        if [ "$chain" = "goerli" ]; then
            response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d @"$file" https://prysm-prater-rest.production.stakefish.link/temporary-cGiFuLC55OHTFE6xnfQI8X7hMO8PFquP/eth/v1/beacon/pool/bls_to_execution_changes)
        elif [ "$chain" = "mainnet" ]; then
            response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d @"$file" https://prysm-mainnet-rest.production.stakefish.link/temporary-cGiFuLC55OHTFE6xnfQI8X7hMO8PFquP/eth/v1/beacon/pool/bls_to_execution_changes)
        fi
        
        if [ "$response" -eq "200" ]; then
            echo "File $file uploaded successfully."
        else
            echo "Error uploading file $file. Response code: $response"
        fi
    fi
done

echo "Done." 