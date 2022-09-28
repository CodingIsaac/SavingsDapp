// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @author Isaac Ijuo
contract Debby is ERC20 {
    address owner;
    uint public constant maxTotalSupply = 30000000 * 10 ** 18;

    /*

    What exactly are we trying to achieve: basically 2:
    1. Users should be able to save their ETH and DEB token into this smart contract.
    2. Users should be able to withdraw their saved tokens from this smart contract at will.
    3. We should guard against reentrancy.
    4. Ensure that users who don't deposit should not withdraw.

    */

    // runs immediately this contract is deployed: sets owner to msg.sender and mints token to contract address
    constructor() ERC20("Debby", "DAB") {
        owner = msg.sender;
        _mint(address(this), maxTotalSupply);
    }

    // mapping to track ETH savings and erc20 lendings
    mapping(address => uint) ethSavings;
    

    // mapping to track ERC20 savings and ETH lending
    mapping(address => uint) erc20Savings;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    
    

    /// @dev deposits ETH to the contract
    function depositEth() external payable {
       
        require(msg.value > 0, "can't send zero eth");
        
        ethSavings[msg.sender] += msg.value;
    }

   

    /// @dev user gets back their ETH saved as collateral
    function getBackEth() external {
       
        require(ethSavings[msg.sender] > 0, "you don't have saved Eth to withdraw");
        require(address(this).balance >= ethSavings[msg.sender], "no funds to payback, check later");

        uint ethSaved = ethSavings[msg.sender];
        ethSavings[msg.sender] = 0;

        payable(msg.sender).transfer(ethSaved);

         _transfer(address(this), msg.sender, ethSaved);
    }

   
    function getContractBalance() external onlyOwner view returns (uint bal) {
        bal = address(this).balance;
    }

    
    function getUserSaving(address _address) external view returns (uint addressBal) {
        addressBal = ethSavings[_address];
    }

    
    function depositErc20(uint _amount) external {
        // require(ethLendings[msg.sender] == 0, "you have an unresolved borrowed transaction");
        require(_amount > 0, "can't deposit zero token");

        erc20Savings[msg.sender] += _amount;
    }

   

    /// @dev get back deposited ERC20 token
    function getBackErc20() external {
        
        require(erc20Savings[msg.sender] > 0, "you don't have any save erc20 token");
        require(balanceOf(address(this)) >= erc20Savings[msg.sender], "insufficient funds, check back later");

        uint savedErc20 = erc20Savings[msg.sender];

        erc20Savings[msg.sender] = 0;
        _transfer(address(this), msg.sender, savedErc20);
    }
}