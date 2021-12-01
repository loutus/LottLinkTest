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

import "../utils/StringUtil.sol";
import "./Iregister.sol";
import "./DecentralOwnable";

contract Register is Iregister, DecentralOwnable{

    using StringUtil for string;


    address public DAOContract;
    // uint256 public pureNameFee;

    struct User{
        string username;
        string info;
        address presenter;
        bytes DAOInfo;
        bool isVIP;
        uint256[] params;
    }

    mapping(address => User) public addrToUser;
    mapping(string => address) public userToAddr;




    /**
     * @dev See {Iregister-registered}.
     */
    function registered(address userAddr) public view returns(bool) {
        return bytes(addrToUser[userAddr].username).length != 0;
    }

    /**
     * @dev See {Iregister-registered}.
     */
    function registered(string memory username) public view returns(bool) {
        return userToAddr[username.lower()] != address(0);
    }

    /**
     * @dev See {Iregister-isPure}.
     */
    function isPure(address userAddr) external view returns(bool){
        return registered(userAddr) 
        && bytes(addrToUser[userAddr].username)[0] != bytes1("_");
    }

    /**
     * @dev See {Iregister-isVIP}.
     */
    function isVIP(address userAddr) external view returns(bool){
        return registered(userAddr)  
        && addrToUser[userAddr].isVIP;
    }

    /**
     * @dev See {Iregister-usernameToAddress}.
     */
    function usernameToAddress(string memory username) public view returns(address userAddr) {
        require(registered(username), "no user by this username");
        return userToAddr[username.lower()];
    }

    /**
     * @dev See {Iregister-addressToUsername}.
     */
    function addressToUsername(address userAddr) external view returns(string memory username) {
        require(registered(userAddr), "no user by this address");
        return addrToUser[userAddr].username;
    }

    /**
     * @dev See {Iregister-addressToProfile}.
     */
    function addressToProfile(address userAddr) external view returns(
        string memory username,
        string memory info,
        bool VIPStatus
    ){
        require(registered(userAddr), "no user by this address");
        return(
            addrToUser[userAddr].username,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    /**
     * @dev See {Iregister-usernameToProfile}.
     */
    function usernameToProfile(string memory username) external view returns(
        address userAddr,
        string memory info,
        bool VIPStatus
    ){
        userAddr = usernameToAddress(username);
        return(
            userAddr,
            addrToUser[userAddr].info,
            addrToUser[userAddr].isVIP
        );
    }

    /**
     * @dev See {Iregister-signIn}.
     */
    function signIn(string memory username, string memory info, string memory presenter) external payable {
        address userAddr = _msgSender();
        require(!registered(username), "this username has been used before");

        bool pureSign;
        if(bytes(username)[0] != bytes1("_")) {
            pureSign = true;
            require(msg.value >= DAO.vars["registerPureFee"], "this username is Payable");
        } else {
            require(msg.value >= DAO.vars["registerNormalFee"], "this username is Payable");
        }

        _setUsername(userAddr, username);

        emit TransferUsername(address(0), userAddr, username);

        if(bytes(info).length > 0) {setInfo(info);}

        address presenterAddr = userToAddr[presenter.lower()];
        (bool success, bytes memory data) = DAOContract.call{value : msg.value}
            (abi.encodeWithSignature("registerSign(address, address, bool)", userAddr, presenterAddr, pureSign));

        if(success){
            addrToUser[userAddr].DAOInfo = abi.decode(data, (string));
        }
    }

    /**
     * @dev See {Iregister-setInfo}.
     */
    function setInfo(string memory info) public {
        address userAddr = _msgSender();
        require(registered(userAddr) , "you have to sign in first");
        addrToUser[userAddr].info = info;
        emit SetInfo(userAddr, info);
    }

    /**
     * @dev See {Iregister-transferUsername}.
     */
    function transferUsername(address _to, bool resetHistory) external {
        address _from = _msgSender();
        string memory username = addressToUsername(_from);

        userToAddr[username.lower()] = _to;

        if (_to != address(0)){
            if (resetHistory) {
                addrToUser[_to].username = username;
            } else {
                addrToUser[_to] = addrToUser[_from];
            }
        }
        delete addrToUser[_from];

        emit TransferUsername(_from, _to, username, resetHistory);
    }

    /**
     * @dev set a `username` to a `userAddr`.
     * 
     * Requirements:
     *
     * - Not allowed empty usernames.
     * - user should not be registered before.
     */
    function _setUsername(address userAddr, string memory username) private {
        require(bytes(username).length > 0, "empty username input");
        require(!registered(userAddr) , "this address has signed a username before");
        addrToUser[userAddr].username = username;
        userToAddr[username.lower()] = userAddr;
    }

    function _userSubParam(address userAddr, uint256 index, uint256 amount) private {
        addrToUser[userAddr].params[index] -= amount;
    }

    function _userAddParam(address userAddr, uint256 index, uint256 amount) private {
        addrToUser[userAddr].params[index] += amount;
    }

    // /**
    //  * @dev Set sign in fee for pure usernames.
    //  */
    // function setPureNameFee(uint256 _fee) public onlyDAO {
    //     pureNameFee = _fee;
    // }

    /**
     * @dev Owner of the contract can upgrade a user to VIP status.
     */
    function upgradeToVIP(address userAddr) external onlyDAO {
        require(registered(userAddr), "no user by this address");
        addrToUser[userAddr].isVIP = true;
    }

}