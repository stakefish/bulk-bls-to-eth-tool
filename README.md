# Bulk BLS to ETH1 replacement tool

This tool generates new withdrawal credentials for multiple validators at once and replaces them with the associated Ethereum wallet address to enable withdrawals, such as voluntary exits and reward sweeping.

## ⚠️ Disclaimer

This tool is intended to be used by **Stakefish** validators only. We do not guarantee the accuracy or correctness of the tool, and using it may result in the loss of your funds. Use at your own risk.

## Usage

1. Install Docker on your machine.
2. Pull the latest version of the Docker image using the following command:
```bash
docker pull stakefishdev/stakefish-bulk-bls-eth-tool:latest
```
3. Run the following command to replace the BLS keys for your deposited validators:
```bash
docker run -e CHAIN=mainnet \
   -e DEPOSITOR_ADDRESS=<depositor-address> \
   -e EXECUTION_ADDRESS=<execution-address> \ 
   -e MNEMONIC="<mnemonic-phrase>" \
   stakefishdev/stakefish-bulk-bls-eth-tool:latest
```
Replace `<chain-name>`, `<depositor-address>`, `<execution-address>`, and `<mnemonic-phrase>` with your specific values. Note that the CHAIN environment variable specifies the Ethereum 1 chain name, and the MNEMONIC environment variable should be set to your 12 or 24-word mnemonic phrase. Make sure that your deposited validators are with Stakefish, as this tool is only intended for use with Stakefish validators.

## MIT License

Copyright (c) 2023 stakefish, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.