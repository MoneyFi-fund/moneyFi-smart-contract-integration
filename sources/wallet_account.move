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
    /// referrer wallet id has been set already
    const E_REFERRER_WALLET_ID_EXISTS: u64 = 9;
    const E_DEPRECATED: u64 = 10;

    // ========================================
    // Structs
    // ========================================

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct WalletAccount has key {
        // wallet_id is a byte array of length 32
        wallet_id: vector<u8>,
        // internal chain ID
        chain_id: u8,
        wallet_address: Option<address>,
        referrer_wallet_id: vector<u8>,
        assets: OrderedMap<address, AccountAsset>,
        system_fee_percent: Option<u64>, // 100 => 1%
        // [level_1, level_2, level_3, ...]
        referral_percents: vector<u64>, // 100 => 1%,
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

    struct WithdrawalState has key {
        asset: OrderedMap<address, WithdrawalAsset>
    }

    struct WithdrawalAsset has store, copy, drop {
        requested_amount: u64,
        // available amount for withdrawal
        available_amount: u64
    }

    // ========================================
    // Public Entry Functions
    // ========================================
    /// Register a new wallet account
    /// @param sender: Signer of the wallet owner
    /// @param verifier: Signer of the verifier
    /// @param wallet_id: Wallet identifier
    /// @param referrer_wallet_id: Referrer's wallet identifier
    public entry fun register(
        sender: &signer,
        verifier: &signer,
        wallet_id: vector<u8>,
        referrer_wallet_id: vector<u8>
    ) {
        abort 0;
    }

    // ========================================
    // View Functions
    // ========================================

    /// Get current amount for a specific asset in a wallet
    /// @param wallet_id: Wallet identifier
    /// @param asset: Asset metadata object
    /// @return u64 - Current amount of the asset in the wallet
    #[view]
    public fun get_current_amount(
        wallet_id: vector<u8>,
        asset: Object<Metadata>
    ): u64;

    /// Get withdrawal state for a specific asset in a wallet
    /// @param wallet_id: Wallet identifier
    /// @param asset: Asset metadata object
    /// @return (requested_amount, available_amount)
    #[view]
    public fun get_withdrawal_state(
        wallet_id: vector<u8>,
        asset: Object<Metadata>
    ): (u64, u64);

    /// Check if a wallet_id is a valid wallet account
    /// @param wallet_id: Wallet identifier
    /// @return bool - True if wallet account exists
    #[view]
    public fun has_wallet_account(wallet_id: vector<u8>): bool;

    /// Get the WalletAccount object for a given wallet_id
    /// @param wallet_id: Wallet identifier
    /// @return Object<WalletAccount> - Wallet account object
    #[view]
    public fun get_wallet_account(wallet_id: vector<u8>): Object<WalletAccount>;

    /// Get a specific asset data for a wallet account
    /// @param wallet_id: Wallet identifier
    /// @param asset: Asset metadata object
    /// @return AccountAsset - Asset data including amounts, LP, rewards, etc.
    #[view]
    public fun get_wallet_account_asset(
        wallet_id: vector<u8>, 
        asset: Object<Metadata>
    ): AccountAsset;

    /// Get all assets data for a wallet account
    /// @param wallet_id: Wallet identifier
    /// @return (asset_addresses, account_assets) - List of asset addresses and their corresponding data
    #[view]
    public fun get_wallet_account_assets(
        wallet_id: vector<u8>
    ): (vector<address>, vector<AccountAsset>);

    /// Get wallet_id from wallet account object
    /// @param object: Wallet account object
    /// @return vector<u8> - Wallet identifier
    #[view]
    public fun get_wallet_id_by_wallet_account(
        object: Object<WalletAccount>
    ): vector<u8>;

    // ========================================
    // Public Functions
    // ========================================

    /// Get the WalletAccount object address for a given wallet_id
    /// @param wallet_id: Wallet identifier
    /// @return address - Wallet account object address
    public fun get_wallet_account_object_address(wallet_id: vector<u8>): address;

    /// Get the owner address for a wallet_id
    /// @param wallet_id: Wallet identifier
    /// @return address - Owner wallet address
    public fun get_owner_address(wallet_id: vector<u8>): address;

    /// Get wallet account object by owner address
    /// @param addr: Owner address
    /// @return Object<WalletAccount> - Wallet account object
    public fun get_wallet_account_by_address(
        addr: address
    ): Object<WalletAccount>;

    /// Get wallet_id by owner address
    /// @param addr: Owner address
    /// @return vector<u8> - Wallet identifier
    public fun get_wallet_id_by_address(
        addr: address
    ): vector<u8>;
}