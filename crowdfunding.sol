// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Crowdfunding {
    mapping(address => uint256) public funders;
    uint256 public deadline;
    uint256 public targetFunds;
    string public name;
    address public owner;
    bool public fundsWithdrawn;

    event Funded(address _funder, uint256 _amount); // add money to the block
    event OwnerWithdraw(uint256 _amount); // successful withdraw of money
    event FunderWithdraw(address _funder, uint256 _amount); // funder withdraw money because failure

    constructor(string memory _name, uint256 _targetFunds, uint256 _deadline) {
        owner = msg.sender;
        name = _name;
        targetFunds = _targetFunds;
        deadline = _deadline;
    }

    // allow a funder to provide for a crowdfunding
    function fund() public payable {
        require(isFundEnabled() == true, "Funding is now disabled");
        funders[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    // allow owner to withdraw the funds
    function withdrawOwner() public {
        require(msg.sender == owner, "Not authorized");
        require(isFundSuccess() == true, "Cannot withdraw!");

        uint256 amountToSend = address(this).balance;
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "unable to send");
        fundsWithdrawn = true;
        emit OwnerWithdraw(amountToSend);
    }

    function withdrawFunder() public {
        require(isFundEnabled() == false && isFundSuccess() == false, "Not eligible");
        uint256 amountToSend = funders[msg.sender];
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "unable to send!");
        funders[msg.sender] = 0; // such that the person doesn't get more funds than required
        emit FunderWithdraw(msg.sender, amountToSend);
    }

    // helper functions
    // check if funds are enabled : if the owner withrawn the funds
    // or the deadline has been passed(is goind to be used in the smart contract)
    function isFundEnabled() public view returns(bool) {
        if(block.timestamp > deadline || fundsWithdrawn) {
            return false;
        } 
        return true;
    }

    // check if funding is completed
    function isFundSuccess() public view returns(bool) {
        if(address(this).balance >= targetFunds || fundsWithdrawn) {
            return true;
        }
        return false;
    }
}
