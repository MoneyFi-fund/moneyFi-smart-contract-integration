module moneyfi::wallet_account {
    use std::option::Option;
    use aptos_framework::ordered_map::OrderedMap;
    use aptos_framework::object::{Object, ExtendRef};
    use aptos_framework::fungible_asset::Metadata;

    // -- Errors
    const E_WALLET_ACCOUNT_EXISTS: u64 = 1;
    const E_WALLET_ACCOUNT_NOT_EXISTS: u64 = 2;
    const E_NOT_APTOS_WALLET_ACCOUNT: u64 = 3;
    const E_NOT_OWNER: u64 = 4;
    const E_WALLET_ACCOUNT_NOT_CONNECTED: u64 = 5;
    const E_WALLET_ACCOUNT_ALREADY_CONNECTED: u64 = 6;
    const E_INVALID_ARGUMENT: u64 = 7;
    const E_STRATEGY_DATA_NOT_EXISTS: u64 = 8;
    const E_REFERRER_WALLET_ID_EXISTS: u64 = 9;
    const E_DEPRECATED: u64 = 10;
    const E_INSUFFICIENT_FUND: u64 = 11;

    // ========================================
    // Structs
    // ========================================

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct WalletAccount has key {
        wallet_id: vector<u8>,
        chain_id: u8,
        wallet_address: Option<address>,
        referrer_wallet_id: vector<u8>,
        assets: OrderedMap<address, AccountAsset>,
        system_fee_percent: Option<u64>,
        referral_percents: vector<u64>,
        extend_ref: ExtendRef
    }

    struct AccountAsset has store, copy, drop {
        current_amount: u64,
        deposited_amount: u64,
        lp_amount: u64,
        swap_out_amount: u64,
        swap_in_amount: u64,
        distributed_amount: u64,
        withdrawn_amount: u64,
        interest_amount: u64,
        interest_share_amount: u64,
        rewards: OrderedMap<address, u64>
    }

    // ========================================
    // Entry Functions
    // ========================================

    /// Register a new wallet account
    /// @param sender: Wallet owner's signer
    /// @param verifier: Verifier signer (MoneyFi system only)
    /// @param wallet_id: Wallet identifier (must be exactly 32 bytes)
    /// @param referrer_wallet_id: Referrer's wallet identifier (can be empty vector)
    public entry fun register(
        sender: &signer,
        verifier: &signer,
        wallet_id: vector<u8>,
        referrer_wallet_id: vector<u8>
    ){
        abort 0;
    }

    // ========================================
    // View Functions
    // ========================================

    /// Get withdrawal state for a specific asset in a wallet
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @param asset: Asset metadata object
    /// @return (u64, u64, bool) - Tuple of (requested_amount, available_amount, is_successful)
    #[view]
    public fun get_withdrawal_state(
        wallet_id: vector<u8>,
        asset: Object<Metadata>
    ): (u64, u64, bool){
        (0,0,true)
    }

    /// Check if a wallet account exists for the given wallet_id
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @return bool - True if wallet account exists, false otherwise
    #[view]
    public fun has_wallet_account(wallet_id: vector<u8>): bool {
        true
    }

    /// Get the WalletAccount object for a given wallet_id
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @return Object<WalletAccount> - Wallet account object
    #[native_interface]
    public fun get_wallet_account(wallet_id: vector<u8>): Object<WalletAccount>;

    /// Get detailed asset data for a specific asset in a wallet account
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @param asset: Asset metadata object
    /// @return AccountAsset - Complete asset data including all amounts, LP tokens, and rewards
    #[native_interface]
    public fun get_wallet_account_asset(
        wallet_id: vector<u8>, 
        asset: Object<Metadata>
    ): AccountAsset;

    /// Get all assets data for a wallet account
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @return (vector<address>, vector<AccountAsset>) - Tuple of asset addresses and their data
    #[native_interface]
    public fun get_wallet_account_assets(
        wallet_id: vector<u8>
    ): (vector<address>, vector<AccountAsset>);

    /// Get wallet_id from a wallet account object
    /// @param object: Wallet account object
    /// @return vector<u8> - Wallet identifier (32 bytes)
    #[native_interface]
    public fun get_wallet_id_by_wallet_account(
        object: Object<WalletAccount>
    ): vector<u8>;

    // ========================================
    // Public Functions
    // ========================================

    /// Get the object address for a wallet account
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @return address - Wallet account object address
    #[native_interface]
    public fun get_wallet_account_object_address(wallet_id: vector<u8>): address;

    /// Get the owner address for a wallet_id
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @return address - Owner wallet address
    #[native_interface]
    public fun get_owner_address(wallet_id: vector<u8>): address;

    /// Get wallet account object by owner address
    /// @param addr: Owner address
    /// @return Object<WalletAccount> - Wallet account object
    #[native_interface]
    public fun get_wallet_account_by_address(
        addr: address
    ): Object<WalletAccount>;

    /// Get wallet_id by owner address
    /// @param addr: Owner address
    /// @return vector<u8> - Wallet identifier (32 bytes)
    #[native_interface]
    public fun get_wallet_id_by_address(
        addr: address
    ): vector<u8>;
}