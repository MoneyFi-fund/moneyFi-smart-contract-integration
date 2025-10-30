module moneyfi::vault {
    use aptos_std::type_info::TypeInfo;
    use aptos_framework::ordered_map::OrderedMap;
    use aptos_framework::object::Object;
    use aptos_framework::fungible_asset::Metadata;
    
    use moneyfi::wallet_account::WalletAccount;

    // ========================================
    // Constants
    // ========================================

    /// Withdraw request status: Pending
    const STATUS_PENDING: u8 = 0;
    
    /// Withdraw request status: Success
    const STATUS_SUCCESS: u8 = 1;
    
    /// Withdraw request status: Failed
    const STATUS_FAILED: u8 = 2;

    // -- Errors
    const E_ALREADY_INITIALIZED: u64 = 1;
    const E_DEPOSIT_NOT_ALLOWED: u64 = 2;
    const E_WITHDRAW_NOT_ALLOWED: u64 = 3;
    const E_ASSET_NOT_SUPPORTED: u64 = 4;
    const E_DEPRECATED: u64 = 5;

    // ========================================
    // Structs
    // ========================================

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

    // ========================================
    // Events
    // ========================================

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
        request_id: u64,
        wallet_id: vector<u8>,
        asset: Object<Metadata>,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct UpdateStatusEvent has drop, store {
        request_id: u64,
        wallet_id: vector<u8>,
        old_status: u8,
        new_status: u8,
        error_message: vector<u8>,
        timestamp: u64
    }

    #[event]
    struct UpsertAssetSupportedEvent has drop, store {
        asset_addr: address,
        min_deposit: u64,
        max_deposit: u64,
        min_withdraw: u64,
        max_withdraw: u64,
        lp_exchange_rate: u64,
        timestamp: u64
    }

    #[event]
    struct ConfigureEvent has drop, store {
        enable_deposit: bool,
        enable_withdraw: bool,
        system_fee_percent: u64,
        referral_percents: vector<u64>,
        fee_recipient: address,
        timestamp: u64
    }

    #[event]
    struct DepositedToStrategyEvent has drop, store {
        wallet_id: vector<u8>,
        asset: Object<Metadata>,
        strategy: TypeInfo,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct WithdrawnFromStrategyEvent has drop, store {
        wallet_id: vector<u8>,
        asset: Object<Metadata>,
        strategy: TypeInfo,
        amount: u64,
        interest_amount: u64,
        system_fee: u64,
        timestamp: u64
    }

    #[event]
    struct SwapAssetsEvent has drop, store {
        wallet_id: vector<u8>,
        strategy: u8,
        from_asset: Object<Metadata>,
        to_asset: Object<Metadata>,
        amount_in: u64,
        amount_out: u64,
        lp_amount_in: u64,
        lp_amount_out: u64,
        timestamp: u64
    }

    #[event]
    struct WithdrawFeeEvent has drop, store {
        asset: Object<Metadata>,
        recipient: address,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct HookEvent has drop, store {
        data: vector<u8>
    }

    #[event]
    struct ClaimReferralFeeEvent has drop, store {
        asset: Object<Metadata>,
        recipient: address,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct ShareFeeEvent has drop, store {
        asset: Object<Metadata>,
        total_fee: u64,
        referral_fees: OrderedMap<address, u64>,
        timestamp: u64
    }

    // ========================================
    // Deposit Function
    // ========================================

    /// Deposit asset into vault and receive LP tokens
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to deposit
    /// @param amount: Amount to deposit
    public entry fun deposit(
        sender: &signer, 
        asset: Object<Metadata>, 
        amount: u64
    );

    // ========================================
    // Withdraw Functions
    // ========================================

    /// Withdraw asset from vault by burning LP tokens
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to withdraw
    /// @param amount: Amount to withdraw
    public entry fun withdraw(
        sender: &signer, 
        asset: Object<Metadata>, 
        amount: u64
    );

    /// Request a withdrawal (asynchronous withdrawal)
    /// Creates a withdrawal request that will be processed by backend
    /// @param sender: User's signer
    /// @param asset: Asset metadata object to withdraw
    /// @param amount: Amount to withdraw
    public entry fun request_withdraw(
        sender: &signer,
        asset: Object<Metadata>,
        amount: u64
    );

    /// Update the status of a withdrawal request
    /// Can only be called by service account (backend)
    /// @param sender: Service account signer
    /// @param wallet_id: Wallet identifier
    /// @param request_id: ID of the withdrawal request
    /// @param new_status: New status (STATUS_PENDING, STATUS_SUCCESS, or STATUS_FAILED)
    /// @param error_message: Error message if status is STATUS_FAILED, empty otherwise
    public entry fun update_withdraw_request_status(
        sender: &signer,
        wallet_id: vector<u8>,
        request_id: u64,
        new_status: u8,
        error_message: vector<u8>
    );

    // ========================================
    // View Functions
    // ========================================

    /// Get list of pending withdrawal request IDs for a wallet
    /// @param wallet_id: Wallet identifier
    /// @return vector<u64> - List of pending request IDs
    #[view]
    public fun get_pending_withdraw_requests(
        wallet_id: vector<u8>
    ): vector<u64>;

    /// Get list of failed withdrawal request IDs for a wallet
    /// @param wallet_id: Wallet identifier
    /// @return vector<u64> - List of failed request IDs
    #[view]
    public fun get_failed_withdraw_requests(
        wallet_id: vector<u8>
    ): vector<u64>;

    /// Get the status and error message of a withdrawal request
    /// @param wallet_id: Wallet identifier
    /// @param request_id: ID of the withdrawal request
    /// @return (u8, vector<u8>) - Tuple of (status, error_message)
    #[view]
    public fun get_withdraw_request_status(
        wallet_id: vector<u8>,
        request_id: u64
    ): (u8, vector<u8>);

    /// Get full details of a withdrawal request
    /// @param wallet_id: Wallet identifier
    /// @param request_id: ID of the withdrawal request
    /// @return WithdrawRequest - Complete request details
    #[view]
    public fun get_withdraw_request(
        wallet_id: vector<u8>,
        request_id: u64
    ): WithdrawRequest;

    /// Get list of all supported assets in vault
    /// @return vector<address> - List of supported asset addresses
    #[view]
    public fun get_supported_assets(): vector<address>;

    /// Get pending referral fees for a specific wallet
    /// @param wallet_id: Wallet identifier
    /// @return OrderedMap<address, u64> - Map of asset address to pending referral fee amount
    #[view]
    public fun get_pending_referral_fees(
        wallet_id: vector<u8>
    ): OrderedMap<address, u64>;

    /// Get asset information (total amount, total LP amount, distributed amount)
    /// @param asset: Asset metadata object
    /// @return (u128, u128, u128) - Tuple of (total_amount, total_lp_amount, total_distributed_amount)
    #[view]
    public fun get_asset(asset: Object<Metadata>): (u128, u128, u128);

    /// Get all assets and their total amounts
    /// @return (vector<address>, vector<u128>) - Tuple of (asset_addresses, total_amounts)
    #[view]
    public fun get_assets(): (vector<address>, vector<u128>);
    
    // ========================================
    // Public Functions
    // ========================================


    /// Create a withdrawal request programmatically
    /// Returns the request ID for tracking
    /// @param account: Wallet account object
    /// @param asset: Asset metadata object to withdraw
    /// @param amount: Amount to withdraw
    /// @return u64 - Request ID
    public fun create_withdraw_request(
        account: &Object<WalletAccount>,
        asset: Object<Metadata>,
        amount: u64
    ): u64;

    /// Get the LP token metadata object
    /// @return Object<Metadata> - LP token object
    public fun get_lp_token(): Object<Metadata>;

    /// Get the vault address
    /// @return address - Vault address
    public fun get_vault_address(): address;
}