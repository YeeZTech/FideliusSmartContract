# Fidelius Smart Contract

This repository contains the Ethereum smart contract for [Fidelius](https://github.com/YeeZTech/YeeZ-Privacy-Computing). Fidelius requires a third party to record and verify data exchange transactions, making a smart contract ideal for this purpose.

Two main challenges arise when incorporating the verification process into the blockchain. Firstly, the storage size limit of the blockchain prevents the direct inclusion of raw or encrypted data. Secondly, complex verification algorithms are hindered by the gas limit.

To tackle these challenges, we employ a variety of cryptographic protocols, implemented in both Fidelius and the smart contract (this repository). While we plan to release documentation on these protocols in the future, you can also refer to the code for details, as code never deceives.

The smart contract is written in Solidity and is designed to run on Ethereum, specifically the Ethereum Virtual Machine (EVM). In theory, it should be straightforward to deploy on any EVM-compatible blockchain. If you encounter any deployment or runtime issues, please feel free to open an issue.

This repository is still undergoing heavy development. As our customers present new scenarios, we find ourselves faced with exciting and challenging tasks. Adapting to these new requirements may involve occasional code refactoring. Despite the potential instability of the codebase, we always prioritize rigorous testing.

## Usage
We utilize [Foundry](https://book.getfoundry.sh/) as our toolchain. Ensure that you have `Foundry` installed, along with `npm`.

### Install Dependencies

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

Given the modular nature of the codebase, you can deploy specific components by writing Foundry deployment scripts.

### Cast

```shell
$ cast <subcommand>
```

## Contribute
If you wish to contribute to this project, feel free to create an issue on our Issue page (e.g., documentation, new ideas, and proposals).

Don't wait until you're fully prepared to contribute. Here are some TODOs:

- Document the smart contracts.
- Remove unused code.
- Provide examples for deploying smart contracts in various scenarios.

## License
This repo is licensed under [The MIT License](https://opensource.org/license/mit).