# AAVE Governance Forge Template

A template for creating AAVE governance Proposal payload contracts.

## Setup

- Rename `.env.example` to `.env`. Add a valid URL for an Ethereum JSON-RPC client for the `FORK_URL` variable
- Follow the [foundry installation instructions](https://github.com/gakonst/foundry#installation)

```
$ forge init --template https://github.com/llama-community/aave-governance-forge-template my-repo
$ cd my-repo
$ forge install
$ npm install
```

## Tests

```
$ make test
```

## Acknowledgements
* [Steven Valeri](https://github.com/stevenvaleri/): Re-wrote AAVE's governance process tests in solidity.
