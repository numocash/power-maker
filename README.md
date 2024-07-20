# 🤖 Numo

![numo_banner](images/numo_readme.png)


The repository contains the smart contract suite for **Numo**, the solidity implementation of a [*replicating market maker*](https://arxiv.org/abs/2103.14769) on the EVM. 

TLDR: Numo allows anyone to short or long any token with leverage using pooled liquidity. 

## Replicating Market Maker

The principle idea of a replicating market maker is that any options strategy can be constructed on the EVM simply by altering the trading function of a CFMM. Thus, turning a CFMM into an *exotic leverage token*.

### Leverage Token 

When someone uses **Numo** to get leverage, they are swapping their token into a leverage token which automatically rebalances at every price to reflect 100x leverage when it hits its strike. Think of it as a 2x leverage token on ETH (ex. ETH2x-FLI), but instead its 100x and supports any token.

## Local development

This project uses [Foundry](https://github.com/foundry-rs/foundry) as the development framework.

### Dependencies

```bash
forge install foundry-rs/forge-std

```
To handle high-percision fixed point airithmic, Numo uses the `PRBMath` Library.
```bash
bun add @prb/math
```
Yu need to add this to your remappings.txt file:

```
@prb/math/=node_modules/@prb/math/
```
For a consistent address across chain deployments, we use `CREATE3`
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
