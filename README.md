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

## Error Codes
| Code | Name                        | Description |
|------|-----------------------------|-------------|
| `1`  | `E_ALREADY_INITIALIZED`     | Vault has already been initialized |
| `2`  | `E_DEPOSIT_NOT_ALLOWED`     | Deposit is not permitted (asset unsupported or vault locked) |
| `3`  | `E_WITHDRAW_NOT_ALLOWED`    | Withdrawal is not permitted (sync disabled or lock period active) |
| `4`  | `E_ASSET_NOT_SUPPORTED`     | Asset is not supported by the vault |
| `5`  | `E_DEPRECATED`              | Function or feature is deprecated |

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

## Public Functions
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

# Module: `moneyfi::wallet_account`

### Purpose

The `wallet_account` module manages user-level account objects, balances, rewards, and referral data.
Each wallet is identified by a `wallet_id` (`vector<u8>` of length 32).

---

## Error Code
| Code | Name                                 | Description |
|------|--------------------------------------|-------------|
| `1`  | `E_WALLET_ACCOUNT_EXISTS`            | Wallet account with this `wallet_id` already exists |
| `2`  | `E_WALLET_ACCOUNT_NOT_EXISTS`        | Wallet account does not exist |
| `3`  | `E_NOT_APTOS_WALLET_ACCOUNT`         | Object is not a valid `WalletAccount` |
| `4`  | `E_NOT_OWNER`                        | Caller is not the wallet owner |
| `5`  | `E_WALLET_ACCOUNT_NOT_CONNECTED`     | Wallet account is not connected to the system |
| `6`  | `E_WALLET_ACCOUNT_ALREADY_CONNECTED` | Wallet account is already connected |
| `7`  | `E_INVALID_ARGUMENT`                 | Invalid argument (wrong length, format, etc.) |
| `8`  | `E_STRATEGY_DATA_NOT_EXISTS`         | Strategy data does not exist for this wallet |
| `9`  | `E_REFERRER_WALLET_ID_EXISTS`        | Referrer wallet ID has already been set |
| `10` | `E_DEPRECATED`                       | Function or feature is deprecated |

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

### `get_current_amount`
```move
#[view]
public fun get_current_amount(
    wallet_id: vector<u8>,
    asset: Object<Metadata>
): u64;
```

### `get_withdrawal_state`
```move
#[view]
public fun get_withdrawal_state(
    wallet_id: vector<u8>,
    asset: Object<Metadata>
): (u64, u64);
```

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

## Withdrawal Request Flow

### User Flow
1. User calls `request_withdraw(sender, asset, amount)`
2. A withdrawal request is created and emit event
3. Backend processes the request
4. User can check with `get_withdrawal_state` or `get_current_amount`
5. User can withdraw full `current_amount` or wait for `current_amount` = `request_amount`
---

## Integration Notes

- Only specific **vault functions** are designed for **direct contract-to-contract integration**.  
- Use `wallet_account::get_wallet_account` to resolve the `WalletAccount` object before interacting with the vault.  
- The `wallet_account::register` function **can only be called by the MoneyFi system** (not by external users or third-party contracts).  
- **Withdrawal requests** are stored per wallet account, not globally. Each request has a unique ID within that wallet's registry.
- LP token accounting, referral tracking, and fee distribution are handled internally by the vault.