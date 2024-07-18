# 🤖 Numo

![Group 224](https://github.com/numotrade/numo/assets/44106773/6e2e3ef8-708c-4e4b-90e6-0d332c9cdea0)

The repository contains the smart contract suite for **Numo**, the solidity implementation of a [*replicating market maker*](https://arxiv.org/abs/2103.14769) on the EVM. 

## A replicating market maker

The principle idea of a replicating market maker is that any options strategy can be constructed on the EVM simply by altering the trading function of a CFMM. **Numo** is built on this premise and has implemented as a trading function that gives traders 100x leverage on any token. Unique to **Numo** is the ability to create any market. It can do this because it requires no oracles or sophisticated market makers.

### Leverage token 

When someone uses **Numo** to get leverage, they are swapping there token into a leverage token which automatically rebalances at every price to reflect 100x leverage. This of it like a 2x leverage token on ETH (ex. ETH2x-FLI), but instead its 100x and supports any token.

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
