// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@paulrberg/contracts/token/erc20/Erc20Permit.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Tickets is ERC20, ERC20Permit, Ownable{
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
        ERC20Permit(_name)
    {}

    function print(address _account, uint256 _amount)
        external
        onlyOwner
    {
        return _mint(_account, _amount);
    }

    function redeem(address _account, uint256 _amount)
        external
        onlyOwner
    {
        return _burn(_account, _amount);
    }
}