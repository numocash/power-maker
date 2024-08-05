# 🤖 Numo

![numo_banner](images/numo_readme.png)

Numo uniquely enables **depeg insurance** on all stablecoins and pegged pairs. One could conversly use Numo to speculate on the fluctuations between pegged tokens.  

The solidity implementation for Numo is contained in this repository and was inspired by math that shows virtually [any option strategy can be constructed using CFMMs](https://arxiv.org/abs/2103.14769). 

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
You need to add this to your remappings.txt file:

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

## Licences

The smart contracts that make up Numo are licensed under the GPL-3.0 unless specified otherwise.