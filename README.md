# Aura Loyalty Rewards

A decentralized retail loyalty and point distribution network built on Base. Aura enables businesses to issue fungible, non-transferable reward points directly to customer wallets, bridging off-chain retail purchases with on-chain cryptographic tracking.

## System Mechanics
* **Isolated Ledger:** Points are strictly scoped to the issuing vendor through nested mappings (`user -> vendor -> points`). Customers cannot erroneously burn vendor A's points at vendor B's location.
* **Verifiable Burn Operations:** Customers interact directly with the smart contract to burn their accumulated points, emitting immutable events that the vendor's Point-of-Sale (POS) system can index to automatically apply discounts.
* **Permissionless Exit:** Vendors retain sovereign control to cancel their specific reward programs without impacting the global state of other participating businesses on the hub.

## Architecture
Built with Solidity `0.8.37`. The protocol favors raw state manipulation over ERC-20 token generation to eliminate unnecessary contract bloat and maintain absolute minimum gas costs for high-frequency retail transactions.
