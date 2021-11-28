// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

contract ERC777TestSender is IERC777Sender{

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");

    constructor(){
        // register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensSender"), address(this));
    }
    
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override{}

    function transfer(address tokenContractAddress, address recipient, uint256 amount) public {
        IERC20 token = IERC20(tokenContractAddress);
        token.transferFrom(msg.sender, recipient, amount);
    }

    function send(address tokenContractAddress, address recipient, uint256 amount) public {
        IERC777 token = IERC777(tokenContractAddress);
        token.operatorSend(msg.sender, recipient, amount, "", "");
    }
}