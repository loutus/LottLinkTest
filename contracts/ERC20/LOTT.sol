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


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./ILOTT.sol";

contract MyToken is ILOTT, ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit, ERC20Votes {
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    function burnFrom(address account, uint256 amount) 
        public
        override(ILOTT, ERC20Burnable)
    {
        super.burnFrom(account, amount);
    }

//     // The following functions are overrides required by Solidity.

//     function _afterTokenTransfer(address from, address to, uint256 amount)
//         internal
//         override(ERC20, ERC20Votes)
//     {
//         super._afterTokenTransfer(from, to, amount);
//         if (from != address(0) && to.isContract()){
//             (bool success, bytes memory data) = to.staticcall(abi.encodeWithSignature("fee()"));
//             uint256 fee = abi.decode(data, (uint256));
//             require(success && amount == fee, "insufficient amount");
//         }
//     }

//     function _mint(address to, uint256 amount)
//         internal
//         override(ERC20, ERC20Votes)
//     {
//         super._mint(to, amount);
//     }

//     function _burn(address account, uint256 amount)
//         internal
//         override(ERC20, ERC20Votes, ERC20Burnable)
//     {
//         super._burn(account, amount);
//     }
}

