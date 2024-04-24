## Fidelius Smart Contract

This repo containts Ethereum smart contract for [Fidelius](https://github.com/YeeZTech/YeeZ-Privacy-Computing). Fidelius needs a third party to record and verify data exchange transactions, and smart contract is perfect for that.

There are two main challenges to put the verification process on blockchain. 
The first challenge is that we cannot put the raw data or encrypted data on blockchain due to the storage size limit of blockchain. The second challenge is that we cannot run complex verification algorithms because of the gas limit.

We involve bunch of cryptographic protocols to overcome these challenges. And the implementation lays in both Fidelius and the smart contract (this repo) sides. 
We shall open our documentation of these protocols in the future. But you may also check the code for details since the code never lies.

The smart contract is written in Solidity, and is designed to run on Ethereum, or EVM specifically. Theoretically, it should be easy to run it on any EVM compatiable blockchains. Feel free to fire an issue if you have any problem to deploy or run it.

This repo is still under heavy development. Our customers always have new scenarios, which is quite exciting and challenging for us. We have to support these new requirements, which means we may refactor our code sometimes. Although the code base may be unstable, we always tries our best to do testing.


## Usage

### Install dependencies

```shell
npm install
forge install
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

The code base is well modulized, and you may deploy what you needs by writing foundry deployment scripts. 

### Cast

```shell
$ cast <subcommand>
```
