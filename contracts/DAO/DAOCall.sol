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

/**
 * @dev this is an abstract contract which provides functions to call DAO contract.
 */
abstract contract DAOCall {

    /**
     * @dev DAOInit eternal address on MATIC MUMBAI testnet.
     */
    address immutable DAOInit = 0x245cAa689Fa16ab50DF4e8ab48555715877F79fF;

    /**
     * @dev returns the current DAO contract address.
     */
    function DAO() public view returns(address DAOAddr){
        (bool success, bytes memory _data) = DAOInit.staticcall(
            abi.encodeWithSignature("DAO()")
        );
        if(success) {return abi.decode(_data, (address));}
    }

    /**
     * @dev returns any `data` assigned to a `tag`.
     */
    function DAOGetBool(bytes32 tag) public view returns(bool data) {
        (bool success, bytes memory _data) = DAO().staticcall(
            abi.encodeWithSignature("getBool(bytes32)", tag)
        );
        if(success) {return abi.decode(_data, (bool));}
    }
    function DAOGetUint(bytes32 tag) public view returns(uint data) {
        (bool success, bytes memory _data) = DAO().staticcall(
            abi.encodeWithSignature("getUint256(bytes32)", tag)
        );
        if(success) {return abi.decode(_data, (uint));}
    }
    function DAOGetInt(bytes32 tag) public view returns(int data) {
        (bool success, bytes memory _data) = DAO().staticcall(
            abi.encodeWithSignature("getUint256(bytes32)", tag)
        );
        if(success) {return abi.decode(_data, (int));}
    }
    function DAOGetAddress(bytes32 tag) public view returns(address data) {
        (bool success, bytes memory _data) = DAO().staticcall(
            abi.encodeWithSignature("getAddress(bytes32)", tag)
        );
        if(success) {return abi.decode(_data, (address));}
    }
    function DAOGetString(bytes32 tag) public view returns(string memory data) {
        (bool success, bytes memory _data) = DAO().staticcall(
            abi.encodeWithSignature("getString(bytes32)", tag)
        );
        if(success) {return abi.decode(_data, (string));}
    }
    function DAOGetBytes(bytes32 tag) public view returns(bytes memory data) {
        (bool success, bytes memory _data) = DAO().staticcall(
            abi.encodeWithSignature("getBoolean(bytes32)", tag)
        );
        if(success) {return abi.decode(_data, (bytes));}
    }


    /**
     * @dev Throws if called by any address except DAO contract.
     */
    modifier onlyDAO() {
        require(
            msg.sender == DAO(),
            "DecentralAccess: restricted access to specific roll"
        );
        _;
    }

    /**
     * @dev Throws if called by any address except specific roll.
     */
    modifier onlyRoll(string memory roll) {
        require(
            DAOGetBool(keccak256(abi.encodePacked(roll, msg.sender))) || msg.sender == DAO(), 
            "DecentralAccess: restricted access to specific roll"
        );
        _;
    }
}