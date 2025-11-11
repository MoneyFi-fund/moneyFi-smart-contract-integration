module moneyfi::vault {
    use std::vector;
    use aptos_framework::ordered_map::{Self, OrderedMap};
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::Metadata;
    
    use moneyfi::wallet_account::WalletAccount;

    // -- Errors
    const E_ALREADY_INITIALIZED: u64 = 1;
    const E_DEPOSIT_NOT_ALLOWED: u64 = 2;
    const E_WITHDRAW_NOT_ALLOWED: u64 = 3;
    const E_ASSET_NOT_SUPPORTED: u64 = 4;
    const E_DEPRECATED: u64 = 5;

    //  -- events

    #[event]
    struct DepositedEvent has drop, store {
        sender: address,
        wallet_account: Object<WalletAccount>,
        asset: Object<Metadata>,
        amount: u64,
        lp_amount: u64,
        timestamp: u64
    }

    #[event]
    struct WithdrawnEvent has drop, store {
        sender: address,
        wallet_account: Object<WalletAccount>,
        asset: Object<Metadata>,
        amount: u64,
        lp_amount: u64,
        timestamp: u64
    }

    #[event]
    struct RequestWithdrawEvent has drop, store {
        wallet_id: vector<u8>,
        asset: Object<Metadata>,
        amount: u64,
        timestamp: u64
    }

    // ========================================
    // Entry Functions
    // ========================================

    /// Deposit asset into vault and receive LP tokens
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to deposit
    /// @param amount: Amount to deposit
    public entry fun deposit(
        sender: &signer, 
        asset: Object<Metadata>, 
        amount: u64
    ){
        abort 0;
    }

    /// Withdraw asset from vault by burning LP tokens (synchronous)
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to withdraw
    /// @param amount: Amount to withdraw
    public entry fun withdraw(
        sender: &signer, 
        asset: Object<Metadata>, 
        amount: u64
    ){
        abort 0;
    }

    /// Request a withdrawal (asynchronous withdrawal)
    /// Creates a withdrawal request that will be processed by backend
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to withdraw
    /// @param amount: Amount to withdraw
    public entry fun request_withdraw(
        sender: &signer,
        asset: Object<Metadata>,
        amount: u64
    ){
        abort 0;
    }

    /// Withdraw asset from an existing withdrawal request
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to withdraw
    public entry fun withdraw_requested_amount(
        sender: &signer, 
        asset: Object<Metadata>
    ){
        abort 0;
    }

    // ========================================
    // View Functions
    // ========================================

    /// Get list of all supported assets in vault
    /// @return vector<address> - List of supported asset addresses
    #[view]
    public fun get_supported_assets(): vector<address> {
        vector::empty()
    }

    /// Estimate the user's total fund value for a given asset.
    ///
    /// This includes:
    /// - User's current asset balances converted to the target asset
    /// - Estimated withdrawable amounts from strategies
    /// - Deduction of system fees if applicable
    /// 
    /// @param user_addr - The user's address
    /// @param asset - Target asset to express the total value in
    /// @return u64 - Estimated total fund value after conversions and fees
    #[view]
    public fun estimate_total_fund_value(user_addr: address, asset: Object<Metadata>): u64 {
        0
    }

    /// Get pending referral fees for a specific wallet
    /// @param wallet_id: Wallet identifier (32 bytes)
    /// @return OrderedMap<address, u64> - Map of asset address to pending referral fee amount
    #[view]
    public fun get_pending_referral_fees(
        wallet_id: vector<u8>
    ): OrderedMap<address, u64> {
        ordered_map::new()
    }

    /// Get asset information (total amount, total LP amount, distributed amount)
    /// @param asset: Asset metadata object
    /// @return (u128, u128, u128) - Tuple of (total_amount, total_lp_amount, total_distributed_amount)
    #[view]
    public fun get_asset(
        asset: Object<Metadata>
    ): (u128, u128, u128){
        (0,0,0)
    }

    /// Get all assets and their total amounts
    /// @return (vector<address>, vector<u128>) - Tuple of (asset_addresses, total_amounts)
    #[view]
    public fun get_assets(): (vector<address>, vector<u128>) {
        (vector::empty(),vector::empty())
    }
    
    // ========================================
    // Public Functions
    // ========================================

    /// Get the LP token metadata object
    /// @return Object<Metadata> - LP token object
    public fun get_lp_token(): Object<Metadata> {
        object::address_to_object<Metadata>(@moneyfi)
    }

    /// Get the vault address
    /// @return address - Vault address
    public fun get_vault_address(): address {
        @moneyfi
    }
}