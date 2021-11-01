// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============================ TEST_1.0.1 ==============================
//   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
//   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
//   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
//   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
//   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
// ======================================================================
//  ================ Open source smart contract on EVM =================
//   =============== Verify Random Function by ChanLink ===============

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRegister {

    /**
     * @dev Emitted when a new user signs in.
     */
    event SignIn(address indexed userAddress, string username);

    /**
     * @dev Emitted when user info sets or changes.
     */
    event SetInfo(address indexed userAddress, string info);


    /**
     * @dev Check if the user has been registered. (by user address)
     */
    function registered(address userAddr) external view returns(bool);

    /**
     * @dev Check if the user has been registered. (by username)
     */
    function registered(string memory username) external view returns(bool);

    /**
     * @dev Check if address `userAddr` registered and its `username` is pure.
     */
    function isPure(address userAddr) external view returns(bool);

    /**
     * @dev Check if `userAddr` registered and the user is VIP.
     */
    function isVIP(address userAddr) external view returns(bool);

    /**
     * @dev Returns the address `userAddr` of the `username`.
     *
     * Requirements:
     *
     * - `username` must be registered.
     */
    function usernameToAddress(string memory username) external view returns(address userAddr);

    /**
     * @dev Returns the `username` of the address `userAddr`.
     *
     * Requirements:
     *
     * - address `userAddr` must be registered before.
     */
    function addressToUsername(address userAddr) external view returns(string memory username);


    /**
     * @dev Returns the `username`, `info` and `VIP status` of the `userAddr`.
     *
     * Requirements:
     *
     * - address `userAddr` must be registered before.
     */
    function addressToProfile(address userAddr) external view returns(
        string memory username,
        string memory info,
        bool VIPstatus
    );

    /**
     * @dev Returns address `userAddr`, `info` and `VIP status of the `username`.
     *
     * Requirements:
     *
     * - `username` must be registered before.
     */
    function usernameToProfile(string memory username) external view returns(
        address userAddr,
        string memory info,
        bool VIPstatus
    );

    /**
     * @dev Sign in the Register contract by adopting a `username`.
     *
     * Pure usernames are payable but new user can sign in free by using `_` in first character of username.
     *
     * Requirements:
     *
     * - Every address can only sign in once and can't change its username.
     * - Not allowed empty usernames.
     * - Usernames are unique so new user has to adopt a username not used before.
     * - new user must introduce a `presenter`.
     *
     * Emits a {SignIn} event.
     */
    function signIn(string memory username, address presenter) external payable;

    /**
     * @dev in addition to the username, every user can set additional personal info .
     *
     * To remove previously info, can be called by empty string input.
     *
     * Requirements:
     *
     * - The user has to register first.
     *
     * Emits a {SetInfo} event.
     */
    function setInfo(string memory info) external;
}