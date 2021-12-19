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

import "./UserData.sol";
import "../DAO/DAOCall.sol";
import "../utils/StringUtil.sol";


contract Register is DAOCall{

    using StringUtil for string;

    /**
     * @dev returns the eternal contract which holds all users registered data.
     */
    function userData() public view returns(UserData){
        return UserData(DAOGetAddress(keccak256("UserData")));
    }

    /**
     * @dev returns true if the user has been registered. (by `username`)
     */
    function registered(string memory username) public view returns(bool) {
        return userData().userAddress(username.lower()) != address(0);
    }

    /**
     * @dev returns true if the user has been registered. (by user `address`)
     */
    function registered(address userAddr) public view returns(bool) {
        return bytes(userData().getString(userAddr, keccak256("username"))).length > 0;
    }

    /**
     * @dev Returns the address `userAddr` of the `username`.
     *
     * Requirements:
     *
     * - `username` should be registered.
     */
    function usernameToAddress(string memory username) public view returns(address userAddr) {
        userAddr = userData().userAddress(username.lower());
        require(userAddr != address(0), "no user by this username");
        return userAddr;
    }

    /**
     * @dev Returns the `username` of the address `userAddr`.
     *
     * Requirements:
     *
     * - address `userAddr` should be registered.
     */
    function addressToUsername(address userAddr) external view returns(string memory username) {
        string memory _username = userData().getString(userAddr, keccak256("username"));
        require(bytes(_username).length > 0, "no user by this address");
        return _username;
    }

    /**
     * @dev Returns the `username` and `info` of the `userAddr`.
     *
     * Requirements:
     *
     * - address `userAddr` should be registered.
     */
    function addressToProfile(address userAddr) external view returns(
        string memory username,
        string memory userInfo
    ){
        UserData UD = userData();
        string memory _username = UD.getString(userAddr, keccak256("username"));
        require(bytes(_username).length > 0, "no user by this address");
        return(
            _username,
            UD.getString(userAddr, keccak256("userInfo"))
        );
    }

    /**
     * @dev Returns address `userAddr` and `info` of the `username`.
     *
     * Requirements:
     *
     * - `username` should be registered.
     */
    function usernameToProfile(string memory username) external view returns(
        address userAddr,
        string memory userInfo
    ){
        UserData UD = userData();
        userAddr = UD.userAddress(username.lower());
        require(userAddr != address(0), "no user by this username");
        return(
            userAddr,
            UD.getString(userAddr, keccak256("userInfo"))
        );
    }

    /**
     * @dev Sign in the Register contract by adopting a `username` and optional info.
     *
     * pure sign fee is more than usual sign.
     * Users can sign in usual by using `_` in the first character of `username`.
     * new user can introduce a string username as `presenter`.
     * 
     * Requirements:
     *
     * - Every address can only sign one username.
     * - Not allowed empty usernames.
     * - User has to adopt a username not taken before.
     */
    function signIn(string memory username, string memory userInfo, string memory presenter) external payable {
        UserData UD = userData();
        address userAddr = msg.sender;
        require(bytes(username).length > 0, "empty username input");
        require(UD.userAddress(username.lower()) == address(0), "username taken");

        bool pureSign;
        if(bytes(username)[0] != bytes1("_")) {
            pureSign = true;
            require(msg.value >= DAOGetUint(keccak256("pureRegisterFee")), "insufficient fee");
        } else {
            require(msg.value >= DAOGetUint(keccak256("normalRegisterFee")), "insufficient fee");
        }

        require(bytes(UD.getString(userAddr, keccak256("username"))).length == 0, "registered before.");
        UD.setUserAddress(username.lower(), userAddr);
        UD.setString(userAddr, keccak256("username"), username);

        if(bytes(userInfo).length > 0) {
            UD.setString(userAddr, keccak256("userInfo"), userInfo);
        }

        address presenterAddr = UD.userAddress(presenter.lower());
        (bool success, bytes memory data) = DAOGetAddress(keccak256("RegisterDAO")).call{value : msg.value}
            (abi.encodeWithSignature("registerSign(address, address, bool)", userAddr, presenterAddr, pureSign));

        if(success){
            UD.setBytes(userAddr, "RegisterDAOData", data);
        }
    }

    /**
     * @dev in addition to the username, every user can set personal info.
     *
     * To remove previously info, it can be called by empty string input.
     *
     * Requirements:
     *
     * - The user has to register first.
     */
    function setInfo(string memory userInfo) public {
        UserData UD = userData();
        address userAddr = msg.sender;
        require(bytes(UD.getString(userAddr, keccak256("username"))).length > 0 , "you have to sign in first");
        UD.setString(userAddr, keccak256("userInfo"), userInfo);
    }
}