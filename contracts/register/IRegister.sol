// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.6 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   ============== Verify Random Function by ChainLink ===============

import "@openzeppelin/contracts/access/Ownable.sol";

interface Iregister {

    /**
     * @dev Emitted when username transfers.
     */
    event TransferUsername(address _from, address _to, bytes username);

    /**
     * @dev Emitted when user info sets or changes.
     */
    event SetInfo(address indexed userAddress, bytes info);


    /**
     * @dev returns true if the user has been registered. (by user `address`)
     */
    function registered(address userAddr) external view returns(bool);

    /**
     * @dev returns true if the user has been registered. (by `username`)
     */
    function registered(bytes memory username) external view returns(bool);

    /**
     * @dev returns true if address `userAddr` registered and its `username` is pure type.
     */
    function isPure(address userAddr) external view returns(bool);

    /**
     * @dev returns true if `userAddr` registered and the user is VIP.
     */
    function isVIP(address userAddr) external view returns(bool);

    /**
     * @dev Returns the address `userAddr` of the `username`.
     *
     * Requirements:
     *
     * - `username` must be registered.
     */
    function usernameToAddress(bytes memory username) external view returns(address userAddr);

    /**
     * @dev Returns the `username` of the address `userAddr`.
     *
     * Requirements:
     *
     * - address `userAddr` must be registered before.
     */
    function addressToUsername(address userAddr) external view returns(bytes memory username);


    /**
     * @dev Returns the `username`, `info` and `VIP status` of the `userAddr`.
     *
     * Requirements:
     *
     * - address `userAddr` must be registered before.
     */
    function addressToProfile(address userAddr) external view returns(
        bytes memory username,
        bytes memory info,
        bool VIPStatus
    );

    /**
     * @dev Returns address `userAddr`, `info` and `VIP status of the `username`.
     *
     * Requirements:
     *
     * - `username` must be registered before.
     */
    function usernameToProfile(bytes memory username) external view returns(
        address userAddr,
        bytes memory info,
        bool VIPStatus
    );

    /**
     * @dev Sign in the Register contract by adopting a `username` and optional info if needed.
     *
     * Pure usernames are payable but new user can sign in free by using `_` in the first character of `username`.
     * new user can introduce a bytes username as `presenter`.
     * 
     * Requirements:
     *
     * - Every address can only sign one username.
     * - Not allowed empty usernames.
     * - Usernames are unique so new user has to adopt a username not used before.
     *
     * Emits a {SignIn} event.
     */
    function signIn(bytes memory username, bytes memory info, bytes memory presenter) external payable;

    /**
     * @dev in addition to the username, every user can set a brief personal info.
     *
     * To remove previously info, it can be called by empty bytes input.
     *
     * Requirements:
     *
     * - The user has to register first.
     *
     * Emits a {SetInfo} event.
     */
    function setInfo(bytes memory info) external;

    /**
     * @dev the user can transfer its user to another address.
     * 
     * When `_to` is zero the username will be free.
     *
     * Requirements:
     *
     * - The user should be registered before.
     *
     * Emits a {TransferUsername} event.
     */
    function transferUsername(address _to) external;
}