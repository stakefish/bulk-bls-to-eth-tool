FROM docker.io/library/python:3.10.5

WORKDIR /app

RUN apt-get update && apt-get install -y curl tar jq

RUN curl -LO https://github.com/ethereum/staking-deposit-cli/releases/download/v2.5.0/staking_deposit-cli-d7b5304-linux-amd64.tar.gz \
    && echo "3f51859d78ad47a3e258470f5a5caf03d19ed1d4307d517325b7bb8f6fcde6ef *staking_deposit-cli-d7b5304-linux-amd64.tar.gz" > SHA256SUMS \
    && sha256sum -c SHA256SUMS 2>&1 | grep OK \
    && tar -zxvf staking_deposit-cli-d7b5304-linux-amd64.tar.gz \
    && rm staking_deposit-cli-d7b5304-linux-amd64.tar.gz \
    && mv ./staking_deposit-cli-d7b5304-linux-amd64/deposit /usr/bin/deposit \
    && chmod +x /usr/bin/deposit

COPY bls-to-eth.sh /app/bls-to-eth.sh

ENV CHAIN="mainnet"
ENV DEPOSITOR_ADDRESS="0x0000000000000000000000000000000000000000"
ENV EXECUTION_ADDRESS="0x0000000000000000000000000000000000000000"
ENV MNEMONIC=""

CMD ["/app/bls-to-eth.sh"]