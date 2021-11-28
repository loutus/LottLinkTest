// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

contract ERC777TestReceiver is IERC777Recipient{

    uint256 constant fee = 1000 * 10 ** 18;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    
    constructor(){
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override{
        require(amount == fee, "insufficient fee");
    }

    function ERC777Balance(address tokenContractAddress) public view returns(uint256) {
        IERC20 token = IERC20(tokenContractAddress);
        return token.balanceOf(address(this));
    }
}