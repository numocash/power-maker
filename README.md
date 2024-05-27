# 🤖 Numo

![Group 224](https://github.com/numotrade/numo/assets/44106773/6e2e3ef8-708c-4e4b-90e6-0d332c9cdea0)

The repository contains the smart contract suite for Numo -- the solidity implementation of a [*replicating market maker*](https://arxiv.org/abs/2103.14769) on the EVM. One that replicates a power⁴ perpetual without needing oracles or sophisticated market makers. The effect is a simple, easy-to-manage way of accessing leverage on any token.

### What is a power⁴ perpetual? 

It's an intsrument that gives you 100x+ leverage depending on the strike price you set. Power perpetuals were invented to simplify the European call option into a single contract with no expirys. Traders can now enchance their leverage or hedging strategies with a crypto-native, high composable, on-chain convexity instrument. 

## Local development

This project uses [Foundry](https://github.com/foundry-rs/foundry) as the development framework.

### Dependencies

```bash
forge install
```

```bash
npm install @openzeppelin/contracts
```

```bash
npm install create3-factory
```

### Compilation

```bash
forge build
```

### Test

```bash
forge test
```

### Local setup

In order to test third party integrations such as interfaces, it is possible to set up a forked mainnet with several positions open

```bash
sh anvil.sh
```

then, in a separate terminal,

```bash
sh setup.sh
```
