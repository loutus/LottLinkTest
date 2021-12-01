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


abstract contract DecentralOwnable {
    address private _DAO;

    event DAOChanged(address indexed previousDAO, address indexed newDAO);



    /**
     * @dev Initializes the contract setting the deployer as the initial DAO.
     */
    constructor(address _DAOAddress) {
        _newDAO(_DAOAddress);
    }

    /**
     * @dev Returns the address of the current DAO.
     */
    function DAO() public view virtual returns (address) {
        return _DAO;
    }


    /**
     * @dev Throws if called by any account other than DAO contract.
     */
    modifier onlyDAO() {
        require(DAO() == msg.sender, "DecentralOwnable: restricted access to DAO");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a `_newDAO`.
     * Can only be called by the current DAO.
     */
    function newDAO(address _newDAO) public onlyDAO {
        address _oldDAO = _DAO;
        _DAO = _newDAO;
        emit DAOChanged(_oldDAO, _newDAO);
    }
}