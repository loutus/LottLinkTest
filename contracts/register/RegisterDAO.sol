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
//   =============== Verify Random Function by ChanLink ===============

import "../ERC20/ILOTT.sol";

contract RegisterDAO{
    
    ILOTT LOTT;

    mapping (string => uint256) public vars;

    address registerContract;

    function setVariable(string[] memory VarName, uint256[] value) public {
        for (uint256 index = 0; index < value.length; index++){
            vars(varName[index]) = value[index];
        }
    }

    function newRegisterAddress(address contractAddr) public {
        registerContract = contractAddr;
    }

    function newLOTTAddress(address contractAddr) public {
        LOTT = ILOTT(contractAddr);
    }

    function updateDAO(address contractAddr, address _newDAO){
        (bool success, bytes memory data) = contractAddr.call(abi.encode("newDAO(address)",  _newDAO));
    }


    function callContract(address contractAddr, bytes inputData){
        (bool success, bytes memory data) = registerContract.call(inputData);
    }


    function registerSign(address signer, address presenter, bool pureSign) public returns(string memory){
        if(pureSign) {
            LOTT.mint(signer, bonus1);
            LOTT.mint(presenter, bonus2);
        } else {
            LOTT.mint(signer, bonus3);
            LOTT.mint(presenter, bonus3);
        }
    }
}