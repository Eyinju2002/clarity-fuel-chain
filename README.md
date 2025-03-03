# FuelChain
A tokenized system for managing fuel logistics on the Stacks blockchain.

## Features
- Create fuel batches with unique identifiers
- Track fuel batch ownership and transfers 
- Record fuel quality metrics and certifications
- Query fuel batch history and current status
- SIP-010 compliant fungible token for fuel trading

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to run the test suite

## Usage Examples
```clarity
;; Create a new fuel batch
(contract-call? .fuel-chain create-batch u1000 "Premium" "Cert123")

;; Transfer batch ownership
(contract-call? .fuel-chain transfer-batch u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Query batch details
(contract-call? .fuel-chain get-batch-details u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
