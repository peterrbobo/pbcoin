# pbcoin

pbcoin is a simple fungible token implemented as a Clarity smart contract and managed with the [Clarinet](https://docs.hiro.so/clarinet) development toolkit.

## Project structure

- `LICENSE` – Project license.
- `README.md` – This file.
- `clarinet/` – Clarinet project containing the pbcoin smart contract and tests.
  - `Clarinet.toml` – Clarinet configuration and contract registry.
  - `contracts/pbcoin.clar` – The pbcoin Clarity smart contract.
  - `settings/` – Network configuration templates.
  - `tests/` – Place for contract tests (TypeScript / Vitest).

## Requirements

- Clarinet CLI (already installed on this machine).
- Node.js (for running the generated Clarinet test tooling, if you choose to write tests).

## pbcoin contract overview

The `pbcoin.clar` contract defines a basic fungible token with:

- Metadata helpers: `get-name`, `get-symbol`, `get-decimals`.
- Accounting helpers: `get-balance`, `get-total-supply`, `get-owner`.
- Lifecycle and supply management:
  - `initialize` – One-time call that sets the contract owner to the caller.
  - `mint` – Owner-only function to mint new tokens to a recipient.
  - `burn` – Allows callers to burn tokens from their own balance.
- Transfers:
  - `transfer` – Moves tokens from the caller to a recipient.

Error codes are defined as constants in `pbcoin.clar`:

- `ERR-NOT-OWNER` (u100)
- `ERR-ALREADY-INITIALIZED` (u101)
- `ERR-NOT-INITIALIZED` (u102)
- `ERR-INSUFFICIENT-BALANCE` (u103)
- `ERR-ZERO-AMOUNT` (u104)

## Usage

### 1. Navigate to the Clarinet project

```bash
cd clarinet
```

### 2. Check contract syntax

From inside the `clarinet/` directory, run:

```bash
clarinet check
```

This validates the syntax of all contracts in `contracts/` and reports any issues.

### 3. Working with the contract in the Clarinet console

You can start a Clarinet REPL to experiment with the contract:

```bash
clarinet console
```

Then, for example, you can call:

```clarity
(contract-call? .pbcoin initialize)
(contract-call? .pbcoin mint u1000 tx-sender)
(contract-call? .pbcoin get-balance tx-sender)
```

### 4. Writing tests

Clarinet scaffolds a TypeScript/Vitest testing setup under `clarinet/tests/`.
You can add tests that exercise the `pbcoin` contract’s public functions.

## Development notes

- The contract owner is initialized using the `initialize` function and is required before minting or burning.
- The initial owner sentinel value is `contract-owner-sentinel`; until `initialize` is called, the contract will return `ERR-NOT-INITIALIZED` for operations that require initialization.
- You can modify the contract logic in `clarinet/contracts/pbcoin.clar` as your token’s requirements evolve.
