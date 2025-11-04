# MoneyFi Vault — Via Contract

## Overview

The **MoneyFi Vault** module provides the main DeFi vault logic that manages user deposits, withdrawals, LP token issuance, referral rewards, and strategy allocations.  
It interacts closely with the `wallet_account` module to track user balances and asset positions.

---

## Module: `moneyfi::vault`

### Purpose
A vault for supported assets that:
- Accepts deposits and issues LP tokens
- Supports **synchronous** (immediate) and **asynchronous** (request-based) withdrawals
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
Deposit a supported asset into the vault. The depositor receives LP tokens proportional to the deposited amount based on the current exchange rate.

**Parameters:**
* `sender`: The user's signer
* `asset`: Asset metadata object to deposit
* `amount`: Amount to deposit (must be within min/max deposit limits)

**Events Emitted:**
* `DepositedEvent` - Contains sender, wallet_account, asset, amount, lp_amount, and timestamp

**Requirements:**
* Asset must be supported by the vault
* Amount must be within configured min/max deposit limits
* Vault deposits must be enabled

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
**Synchronous withdrawal** - Withdraw an asset from the vault immediately by burning the corresponding LP tokens. This operation completes in the same transaction.

**Parameters:**
* `sender`: The user's signer
* `asset`: Asset metadata object to withdraw
* `amount`: Amount to withdraw (must be within min/max withdraw limits)

**Events Emitted:**
* `WithdrawnEvent` - Contains sender, wallet_account, asset, amount, lp_amount, and timestamp

**Requirements:**
* Asset must be supported by the vault
* Amount must be within configured min/max withdraw limits
* Vault withdrawals must be enabled
* Sufficient liquidity must be available in the vault
* User must have sufficient LP tokens

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
**Asynchronous withdrawal** - Create a withdrawal request that will be processed later by the backend service. Use this when immediate liquidity is not available or for larger withdrawals that need processing time.

**Parameters:**
* `sender`: The user's signer
* `asset`: Asset metadata object to withdraw
* `amount`: Amount to withdraw

**Events Emitted:**
* `RequestWithdrawEvent` - Contains request_id, wallet_id, asset, amount, and timestamp

**Requirements:**
* User must have sufficient balance to cover the requested amount
* Request is queued and processed by backend service

**Note:** After requesting, users should monitor their withdrawal state using `get_withdrawal_state` to check when funds are available.

---

### `withdraw_requested_amount`
```move
public entry fun withdraw_requested_amount(
    sender: &signer,
    asset: Object<Metadata>
)
```

**Description:**
Complete a withdrawal from an existing withdrawal request. This function withdraws the **available amount** that has been prepared by the backend service.

**Parameters:**
* `sender`: The user's signer
* `asset`: Asset metadata object to withdraw

**Events Emitted:**
* `WithdrawnEvent` - Contains sender, wallet_account, asset, amount, lp_amount, and timestamp

**Requirements:**
* Must have an existing withdrawal request for the specified asset
* Available amount must be greater than 0 (backend must have processed the request)

**Note:** This function withdraws whatever amount is currently available, which may be less than the originally requested amount if the request is still being processed.

---

## View Functions
```move
public fun get_lp_token(): Object<Metadata>
```

**Description:**
Get the LP token metadata object issued by the vault.

**Returns:**
* `Object<Metadata>` - LP token metadata object

---

### `get_vault_address`
```move
public fun get_vault_address(): address
```

**Description:**
Return the on-chain address of the vault object.

**Returns:**
* `address` - Vault address

---

## View Functions

### `get_supported_assets`
```move
#[view]
public fun get_supported_assets(): vector<address>
```

**Description:**
Return all supported asset addresses in the vault.

**Returns:**
* `vector<address>` - List of supported asset addresses

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

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)

**Returns:**
* `OrderedMap<address, u64>` - Map of asset address to pending referral fee amount

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

**Parameters:**
* `asset`: Asset metadata object

**Returns:**
* `(u128, u128, u128)` - Tuple of (total_amount, total_lp_amount, total_distributed_amount)

---

### `get_assets`
```move
#[view]
public fun get_assets(): (vector<address>, vector<u128>)
```

**Description:**
Return a list of all asset addresses and their total amounts in the vault.

**Returns:**
* `(vector<address>, vector<u128>)` - Tuple of (asset_addresses, total_amounts)

---

## Public Functions
### `get_lp_token`
```move
public fun get_lp_token(): Object<Metadata>
```

**Description:**
Get the LP token metadata object issued by the vault.

**Returns:**
* `Object<Metadata>` - LP token metadata object

---

### `get_vault_address`
```move
public fun get_vault_address(): address
```

**Description:**
Return the on-chain address of the vault object.

**Returns:**
* `address` - Vault address

---

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
| `11` | `E_INSUFFICIENT_FUND`                | Insufficient funds to request withdrawal |
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

**Parameters:**
* `sender`: Wallet owner's signer
* `verifier`: Verifier signer (authorization check - **MoneyFi system only**)
* `wallet_id`: Wallet identifier (must be exactly 32 bytes)
* `referrer_wallet_id`: Referrer's wallet ID (can be empty vector if no referrer)

**Requirements:**
* Wallet ID must be exactly 32 bytes
* Wallet ID must not already exist
* Must be called with valid verifier signature

---

## View Functions

### `get_withdrawal_state`
```move
#[view]
public fun get_withdrawal_state(
    wallet_id: vector<u8>,
    asset: Object<Metadata>
): (u64, u64, bool)
```

**Description:**
Get the withdrawal request state for a specific asset in a wallet.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)
* `asset`: Asset metadata object

**Returns:**
* `(u64, u64, bool)` - Tuple of:
  - `requested_amount`: Total amount requested for withdrawal
  - `available_amount`: Amount currently available to withdraw
  - `is_successful`: Whether the request check was successful

---

### `has_wallet_account`
```move
#[view]
public fun has_wallet_account(
    wallet_id: vector<u8>
): bool
```

**Description:**
Check if a wallet account exists for the given wallet_id.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)

**Returns:**
* `bool` - True if wallet account exists, false otherwise

---

### `get_wallet_account`
```move
#[view]
public fun get_wallet_account(
    wallet_id: vector<u8>
): Object<WalletAccount>
```

**Description:**
Get the WalletAccount object for a given wallet_id.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)

**Returns:**
* `Object<WalletAccount>` - Wallet account object

---

### `get_wallet_account_asset`
```move
#[view]
public fun get_wallet_account_asset(
    wallet_id: vector<u8>,
    asset: Object<Metadata>
): AccountAsset
```

**Description:**
Get detailed asset data for a specific asset in a wallet account.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)
* `asset`: Asset metadata object

**Returns:**
* `AccountAsset` - Complete asset data including all amounts, LP tokens, and rewards

---

### `get_wallet_account_assets`
```move
#[view]
public fun get_wallet_account_assets(
    wallet_id: vector<u8>
): (vector<address>, vector<AccountAsset>)
```

**Description:**
Get all assets data for a wallet account.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)

**Returns:**
* `(vector<address>, vector<AccountAsset>)` - Tuple of:
  - List of asset addresses
  - Corresponding AccountAsset data for each asset

---

### `get_wallet_id_by_wallet_account`
```move
#[view]
public fun get_wallet_id_by_wallet_account(
    object: Object<WalletAccount>
): vector<u8>
```

**Description:**
Get wallet_id from a wallet account object.

**Parameters:**
* `object`: Wallet account object

**Returns:**
* `vector<u8>` - Wallet identifier (32 bytes)

---

## Public Functions

### `get_wallet_account_object_address`
```move
public fun get_wallet_account_object_address(
    wallet_id: vector<u8>
): address
```

**Description:**
Get the object address for a wallet account.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)

**Returns:**
* `address` - Wallet account object address

---

### `get_owner_address`
```move
public fun get_owner_address(
    wallet_id: vector<u8>
): address
```

**Description:**
Get the owner address for a wallet_id.

**Parameters:**
* `wallet_id`: Wallet identifier (32 bytes)

**Returns:**
* `address` - Owner wallet address

---

### `get_wallet_account_by_address`
```move
public fun get_wallet_account_by_address(
    addr: address
): Object<WalletAccount>
```

**Description:**
Get wallet account object by owner address.

**Parameters:**
* `addr`: Owner address

**Returns:**
* `Object<WalletAccount>` - Wallet account object

---

### `get_wallet_id_by_address`
```move
public fun get_wallet_id_by_address(
    addr: address
): vector<u8>
```

**Description:**
Get wallet_id by owner address.

**Parameters:**
* `addr`: Owner address

**Returns:**
* `vector<u8>` - Wallet identifier (32 bytes)

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

1. The user calls `request_withdraw(sender, asset, amount)`.
2. A withdrawal request is created and an event is emitted.
3. The backend processes the withdrawal request.
4. The user can check the status using `get_withdrawal_state`.
   * If `is_successful` is `true`, the withdrawal process is complete.
5. The user calls `withdraw_requested_amount` to withdraw the entire available amount.

## Integration Notes

- Only specific **vault functions** are designed for **direct contract-to-contract integration**.  
- Use `wallet_account::get_wallet_account` to resolve the `WalletAccount` object before interacting with the vault.  
- The `wallet_account::register` function **can only be called by the MoneyFi system** (not by external users or third-party contracts).  
- **Withdrawal requests** are stored per wallet account, not globally
- LP token accounting, referral tracking, and fee distribution are handled internally by the vault.