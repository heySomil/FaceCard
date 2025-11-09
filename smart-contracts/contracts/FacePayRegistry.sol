// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FacePayRegistry
 * @dev Username registry for FacePay - maps @username to wallet address
 */
contract FacePayRegistry {
    
    // Mappings
    mapping(string => address) public usernameToWallet;
    mapping(address => string) public walletToUsername;
    mapping(string => bool) private usernameExists;
    
    // Events
    event UsernameRegistered(string indexed username, address indexed wallet, uint256 timestamp);
    event UsernameUpdated(address indexed wallet, string oldUsername, string newUsername, uint256 timestamp);
    
    // Errors
    error UsernameEmpty();
    error UsernameTaken();
    error AddressAlreadyHasUsername();
    error UsernameNotFound();
    error InvalidUsername();
    
    /**
     * @dev Register a new username for the sender's address
     * @param username The username to register (without @ symbol)
     */
    function register(string memory username) external {
        // Validations
        if (bytes(username).length == 0) revert UsernameEmpty();
        if (bytes(username).length > 20) revert InvalidUsername();
        if (usernameExists[username]) revert UsernameTaken();
        if (bytes(walletToUsername[msg.sender]).length > 0) revert AddressAlreadyHasUsername();
        
        // Register username
        usernameToWallet[username] = msg.sender;
        walletToUsername[msg.sender] = username;
        usernameExists[username] = true;
        
        emit UsernameRegistered(username, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Update username for the sender's address
     * @param newUsername The new username to set
     */
    function updateUsername(string memory newUsername) external {
        string memory oldUsername = walletToUsername[msg.sender];
        
        // Validations
        if (bytes(oldUsername).length == 0) revert UsernameNotFound();
        if (bytes(newUsername).length == 0) revert UsernameEmpty();
        if (bytes(newUsername).length > 20) revert InvalidUsername();
        if (usernameExists[newUsername]) revert UsernameTaken();
        
        // Update mappings
        delete usernameToWallet[oldUsername];
        delete usernameExists[oldUsername];
        
        usernameToWallet[newUsername] = msg.sender;
        walletToUsername[msg.sender] = newUsername;
        usernameExists[newUsername] = true;
        
        emit UsernameUpdated(msg.sender, oldUsername, newUsername, block.timestamp);
    }
    
    /**
     * @dev Resolve username to wallet address
     * @param username The username to resolve
     * @return The wallet address associated with the username
     */
    function resolve(string memory username) external view returns (address) {
        address wallet = usernameToWallet[username];
        if (wallet == address(0)) revert UsernameNotFound();
        return wallet;
    }
    
    /**
     * @dev Get username for a wallet address
     * @param wallet The wallet address
     * @return The username associated with the wallet
     */
    function getUsername(address wallet) external view returns (string memory) {
        return walletToUsername[wallet];
    }
    
    /**
     * @dev Check if a username is available
     * @param username The username to check
     * @return true if available, false if taken
     */
    function isUsernameAvailable(string memory username) external view returns (bool) {
        return !usernameExists[username];
    }
    
    /**
     * @dev Check if an address has a registered username
     * @param wallet The wallet address to check
     * @return true if has username, false otherwise
     */
    function hasUsername(address wallet) external view returns (bool) {
        return bytes(walletToUsername[wallet]).length > 0;
    }
}
