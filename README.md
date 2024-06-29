# 🤖 Numo2

![Group 224](https://github.com/numotrade/numo/assets/44106773/6e2e3ef8-708c-4e4b-90e6-0d332c9cdea0)

The repository contains the smart contract suite for **Numo2**, the solidity implementation of a [*replicating market maker*](https://arxiv.org/abs/2103.14769) on the EVM. 

## A replicating market maker

The principle idea of a replicating market maker is that any options strategy can be constructed on the EVM simply by altering the trading function of a CFMM. 

**Numo2** is built on this premise and has implemented as a trading function that quadruples the returns of any token across every price. Unique to **Numo2** is its support for any token. It can do this because it requires no oracles or sophisticated market makers. The result is a simple way of accessing leverage on any token.

### Quadrupling returns strategy 

**Numo2** runs a continous automated options strategy that quadruples your returns at every price up until you hit your strike price. The strategy is implemented as a **trading function** of the automated market maker so that the pools of tokens always rebalance to reflect a *leveraged position*. 

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
