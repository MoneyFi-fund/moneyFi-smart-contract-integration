# MoneyFi Vault — Via Contract
## Overview

The **MoneyFi Vault** module provides the main DeFi vault logic that manages user deposits, withdrawals, LP token issuance, referral rewards, and strategy allocations.  
It interacts closely with the `wallet_account` module to track user balances and asset positions.

---

## Module: `moneyfi::vault`

### Purpose
A vault for supported assets that:
- Accepts deposits and issues LP tokens
- Supports synchronous and asynchronous withdrawals
- Manages referral and system fees
- Interfaces with investment strategies and fee sharing logic

---

### Constants

| Name | Type | Description |
|------|------|-------------|
| `STATUS_PENDING` | `u8 = 0` | Withdrawal request is pending |
| `STATUS_SUCCESS` | `u8 = 1` | Withdrawal request succeeded |
| `STATUS_FAILED`  | `u8 = 2` | Withdrawal request failed |

---

### Data Structures

#### `WithdrawRequest`
```move
struct WithdrawRequest has store, drop, copy {
    request_id: u64,
    wallet_id: vector<u8>,
    asset: Object<Metadata>,
    amount: u64,
    status: u8,
    requested_at: u64,
    updated_at: u64,
    error_message: vector<u8>
}
```

Represents a withdrawal request with its status and metadata.

---

## Entry Functions

### `deposit`
```move
public entry fun deposit(
    sender: &signer,
    asset: Object<Metadata>,
    amount: u64
)
```

**Description:**
Deposit a supported asset into the vault. The depositor receives LP tokens proportional to the deposited amount.

**Parameters**

* `sender`: The user's signer.
* `asset`: Asset metadata object.
* `amount`: Amount to deposit.

---

### `withdraw`
```move
public entry fun withdraw(
    sender: &signer,
    asset: Object<Metadata>,
    amount: u64
)
```

**Description:**
Withdraw an asset from the vault by burning the corresponding LP tokens. This is a synchronous withdrawal that happens immediately.

**Parameters**

* `sender`: The user's signer.
* `asset`: Asset metadata object.
* `amount`: Amount to withdraw.

---

### `request_withdraw`
```move
public entry fun request_withdraw(
    sender: &signer,
    asset: Object<Metadata>,
    amount: u64
)
```

**Description:**
Create an asynchronous withdrawal request that will be processed later by a service account (backend). The request is stored in the wallet account's registry.

**Parameters**

* `sender`: The user's signer.
* `asset`: Asset metadata object.
* `amount`: Amount to withdraw.

**Events Emitted:**
* `RequestWithdrawEvent` - Contains request_id, wallet_id, asset, amount, and timestamp

---

### `update_withdraw_request_status`
```move
public entry fun update_withdraw_request_status(
    sender: &signer,
    wallet_id: vector<u8>,
    request_id: u64,
    new_status: u8,
    error_message: vector<u8>
)
```

**Description:**
Update the status of a pending withdrawal request.
Only callable by an authorized service account.

**Parameters**

* `sender`: Service account signer.
* `wallet_id`: Wallet identifier (32 bytes).
* `request_id`: Withdrawal request ID.
* `new_status`: One of `STATUS_PENDING`, `STATUS_SUCCESS`, or `STATUS_FAILED`.
* `error_message`: Error message when status is `STATUS_FAILED`, empty otherwise.

**Events Emitted:**
* `UpdateStatusEvent` - Contains request_id, wallet_id, old_status, new_status, error_message, and timestamp

---

## Public Functions

### `create_withdraw_request`
```move
public fun create_withdraw_request(
    account: &Object<WalletAccount>,
    asset: Object<Metadata>,
    amount: u64
): u64
```

**Description:**
Create a withdrawal request programmatically. Returns the request ID for tracking. This function can be called by other contracts for integration purposes.

**Parameters**

* `account`: Wallet account object.
* `asset`: Asset metadata object.
* `amount`: Amount to withdraw.

**Returns:**
* `u64` - The created request ID

---

### `get_lp_token`
```move
public fun get_lp_token(): Object<Metadata>
```

**Description:**
Get the LP token metadata object issued by the vault.

---

### `get_vault_address`
```move
public fun get_vault_address(): address
```

**Description:**
Return the on-chain address of the vault object.

---

## View Functions

### `get_pending_withdraw_requests`
```move
#[view]
public fun get_pending_withdraw_requests(
    wallet_id: vector<u8>
): vector<u64>
```

**Description:**
Get all pending withdrawal request IDs for a specific wallet.

**Parameters**

* `wallet_id`: Wallet identifier (32 bytes).

**Returns:**
* `vector<u64>` - List of pending request IDs

---

### `get_failed_withdraw_requests`
```move
#[view]
public fun get_failed_withdraw_requests(
    wallet_id: vector<u8>
): vector<u64>
```

**Description:**
Get all failed withdrawal request IDs for a specific wallet.

**Parameters**

* `wallet_id`: Wallet identifier (32 bytes).

**Returns:**
* `vector<u64>` - List of failed request IDs

---

### `get_withdraw_request_status`
```move
#[view]
public fun get_withdraw_request_status(
    wallet_id: vector<u8>,
    request_id: u64
): (u8, vector<u8>)
```

**Description:**
Get the status and error message for a specific withdrawal request.

**Parameters**

* `wallet_id`: Wallet identifier (32 bytes).
* `request_id`: Withdrawal request ID.

**Returns:**
* `(u8, vector<u8>)` - Tuple of (status, error_message)

---

### `get_withdraw_request`
```move
#[view]
public fun get_withdraw_request(
    wallet_id: vector<u8>,
    request_id: u64
): WithdrawRequest
```

**Description:**
Get the complete details of a withdrawal request.

**Parameters**

* `wallet_id`: Wallet identifier (32 bytes).
* `request_id`: Withdrawal request ID.

**Returns:**
* `WithdrawRequest` - Complete request details including all metadata

---

### `get_supported_assets`
```move
#[view]
public fun get_supported_assets(): vector<address>
```

**Description:**
Return all supported asset addresses in the vault.

---

### `get_pending_referral_fees`
```move
#[view]
public fun get_pending_referral_fees(
    wallet_id: vector<u8>
): OrderedMap<address, u64>
```

**Description:**
Return a mapping of pending referral fees (asset → amount) for a given wallet.

---

### `get_asset`
```move
#[view]
public fun get_asset(
    asset: Object<Metadata>
): (u128, u128, u128)
```

**Description:**
Return the total amount, total LP supply, and total distributed amount for an asset.

---

### `get_assets`
```move
#[view]
public fun get_assets(): (vector<address>, vector<u128>)
```

**Description:**
Return a list of all asset addresses and their total amounts in the vault.

---

## Withdrawal Request Flow

### User Flow
1. User calls `request_withdraw(sender, asset, amount)`
2. A withdrawal request is created and stored in the wallet account's registry
3. User can query pending requests using `get_pending_withdraw_requests(wallet_id)`
4. Backend processes the request and calls `update_withdraw_request_status(...)`
5. User can check status using `get_withdraw_request_status(wallet_id, request_id)`
---

# Module: `moneyfi::wallet_account`

### Purpose

The `wallet_account` module manages user-level account objects, balances, rewards, and referral data.
Each wallet is identified by a `wallet_id` (`vector<u8>` of length 32).

---

## Entry Functions

### `register`
```move
public entry fun register(
    sender: &signer,
    verifier: &signer,
    wallet_id: vector<u8>,
    referrer_wallet_id: vector<u8>
)
```

**Description:**
Register a new wallet account and associate it with an owner and optional referrer.

**Parameters**

* `sender`: Wallet owner's signer.
* `verifier`: Verifier signer (authorization check).
* `wallet_id`: Wallet identifier (32 bytes).
* `referrer_wallet_id`: Referrer's wallet ID.

---

## View Functions

### `has_strategy_data`
```move
#[view]
public fun has_strategy_data<T: store>(
    wallet_id: vector<u8>
): bool
```

### `has_wallet_account`
```move
#[view]
public fun has_wallet_account(
    wallet_id: vector<u8>
): bool
```

### `get_wallet_account`
```move
#[view]
public fun get_wallet_account(
    wallet_id: vector<u8>
): Object<WalletAccount>
```

### `get_wallet_account_asset`
```move
#[view]
public fun get_wallet_account_asset(
    wallet_id: vector<u8>,
    asset: Object<Metadata>
): AccountAsset
```

### `get_wallet_account_assets`
```move
#[view]
public fun get_wallet_account_assets(
    wallet_id: vector<u8>
): (vector<address>, vector<AccountAsset>)
```

### `get_wallet_id_by_wallet_account`
```move
#[view]
public fun get_wallet_id_by_wallet_account(
    object: Object<WalletAccount>
): vector<u8>
```

---

## Public Functions

### `get_wallet_account_object_address`
```move
public fun get_wallet_account_object_address(
    wallet_id: vector<u8>
): address
```

### `get_owner_address`
```move
public fun get_owner_address(
    wallet_id: vector<u8>
): address
```

### `get_wallet_account_by_address`
```move
public fun get_wallet_account_by_address(
    addr: address
): Object<WalletAccount>
```

### `get_wallet_id_by_address`
```move
public fun get_wallet_id_by_address(
    addr: address
): vector<u8>
```

---

# Package Manifest
```toml
[package]
name = "moneyfi"
version = "1.2.3"
authors = []

[addresses]
moneyfi = "0x97c9ffc7143c5585090f9ade67d19ac95f3b3e7008ed86c73c947637e2862f56"

[dependencies.AptosFramework]
git = "https://github.com/aptos-labs/aptos-framework.git"
rev = "mainnet"
subdir = "aptos-framework"
```

---

## Integration Notes

- Only specific **vault functions** are designed for **direct contract-to-contract integration**.  
- Use `wallet_account::get_wallet_account` to resolve the `WalletAccount` object before interacting with the vault.  
- The `wallet_account::register` function **can only be called by the MoneyFi system** (not by external users or third-party contracts).  
- **Asynchronous withdrawals** are stored in the wallet account's registry and require an external service (backend) to process and update their status using `update_withdraw_request_status`.
- **Withdrawal requests** are stored per wallet account, not globally. Each request has a unique ID within that wallet's registry.
- LP token accounting, referral tracking, and fee distribution are handled internally by the vault.