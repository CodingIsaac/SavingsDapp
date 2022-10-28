// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


/// @author Isaac Ijuo
contract Debby  {
    address owner;
    
    /*

    What exactly are we trying to achieve: basically 2:
    1. Users should be able to save their ETH and Dstake their tokens.
    2. Users should be able to withdraw their saved tokens from this smart contract at will.
    3. We should guard against reentrancy.
    4. Ensure that users who don't deposit should not withdraw.

    */

    
    // mapping to track ETH savings 
    mapping(address => uint) ethSavings;

    struct stakeData {
        uint noOfDays;
        uint amount;
        uint specifiedYear;


    }

    mapping(address => stakeData) stakes;

    constructor() {
        owner = msg.sender;
    }
    receive() external payable {}
    fallback() external payable{}
    

    

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

        
    }

   
    function getContractBalance() external onlyOwner view returns (uint bal) {
        bal = address(this).balance;
    }

    
    function getUserSaving(address _address) external view returns (uint addressBal) {
        addressBal = ethSavings[_address];
    }

    // Function to stake ETH
    function stake(uint specifiedDays) external payable {
        require(msg.value > 0, "You can't stake Zero ETH");
        require(specifiedDays > 0, "Staking period must be greater than Zero days");
        stakeData storage sData = stakes[msg.sender];
        sData.amount += msg.value;
        sData.noOfDays = block.timestamp + (specifiedDays * 1 days);
        sData.specifiedYear = block.timestamp + 365 days;
    }
// Function to calcualte apy
    function toCalculateAPY(uint _days, uint _amount, uint _specifiedyear) private pure returns (uint totalyield) {
        uint quoficientOfDays = _days/_specifiedyear;
        totalyield = quoficientOfDays * _amount;
    }
    // Function to withdraw staked ETH

    function withdrawStake() external {
        stakeData memory userStake = stakes[msg.sender];
        require(block.timestamp > userStake.noOfDays, "Staking period not reached");
        require(userStake.amount > 0, "Insufficient Balance");
        uint calculateAPY = toCalculateAPY(userStake.noOfDays, userStake.amount, userStake.specifiedYear);

        uint ethTransferrable = userStake.amount + calculateAPY;
        stakes[msg.sender].amount = 0;
        stakes[msg.sender].noOfDays = 0;
        payable(msg.sender).transfer(ethTransferrable);

    }



    
   
}