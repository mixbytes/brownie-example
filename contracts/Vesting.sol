// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vesting is Ownable {
    using SafeMath for uint256;

    uint256 constant internal SECONDS_PER_DAY = 86400;

    struct Grant {
        uint256 startTime;
        uint256 amount;
        uint256 vestingDuration;
        uint256 daysClaimed;
        uint256 totalClaimed;
        address recipient;
    }

    event GrantAdded(address recipient, uint256 vestingId);
    event GrantClaimed(address recipient, uint256 amountClaimed);
    event GrantRemoved(address recipient, uint256 amountVested, uint256 amountNotVested);

    IERC20 public token;
    
    mapping (uint256 => Grant) public tokenGrants;
    mapping (address => uint256[]) private activeGrants;
    uint256 public totalVestingCount;

    constructor(IERC20 _token) public {
        require(address(_token) != address(0));
        token = _token;
    }
    

    function getActiveGrants(address _recipient) public view returns(uint256[] memory){
        return activeGrants[_recipient];
    }

    function calculateGrantClaim(uint256 _grantId) public view returns (uint256, uint256) {
        Grant storage tokenGrant = tokenGrants[_grantId];

        if (block.timestamp < tokenGrant.startTime) {
            return (0, 0);
        }

        uint elapsedTime = block.timestamp.sub(tokenGrant.startTime);
        uint elapsedDays = elapsedTime.div(SECONDS_PER_DAY);

        // If over vesting duration, all tokens vested
        if (elapsedDays >= tokenGrant.vestingDuration) {
            uint256 remainingGrant = tokenGrant.amount.sub(tokenGrant.totalClaimed);
            return (tokenGrant.vestingDuration, remainingGrant);
        } else {
            uint256 daysVested = elapsedDays.sub(tokenGrant.daysClaimed);
            uint256 amountVested = tokenGrant.amount.mul(daysVested).div(uint256(tokenGrant.vestingDuration));
            return (daysVested, amountVested);
        }
    }


    function addGrant(
        address _recipient,
        uint256 _startTime,
        uint256 _amount,
        uint16 _vestingDurationInDays  
    ) 
        external
        onlyOwner
    {
        require(_vestingDurationInDays <= 25*365, "more than 25 years");
        
        uint256 amountVestedPerDay = _amount.div(_vestingDurationInDays);
        require(amountVestedPerDay > 0, "amountVestedPerDay > 0");

        // Transfer the grant tokens under the control of the vesting contract
        require(token.transferFrom(owner(), address(this), _amount), "transfer failed");

        Grant memory grant = Grant({
            startTime: _startTime == 0 ? block.timestamp : _startTime,
            amount: _amount,
            vestingDuration: _vestingDurationInDays,
            daysClaimed: 0,
            totalClaimed: 0,
            recipient: _recipient
        });
        tokenGrants[totalVestingCount] = grant;
        activeGrants[_recipient].push(totalVestingCount);
        emit GrantAdded(_recipient, totalVestingCount);
        totalVestingCount++;
    }

    function removeGrant(uint256 _grantId) 
        external 
        onlyOwner
    {
        Grant storage tokenGrant = tokenGrants[_grantId];
        address recipient = tokenGrant.recipient;
        uint256 daysVested;
        uint256 amountVested;
        (daysVested, amountVested) = calculateGrantClaim(_grantId);

        uint256 amountNotVested = (tokenGrant.amount.sub(tokenGrant.totalClaimed)).sub(amountVested);

        require(token.transfer(recipient, amountVested));
        require(token.transfer(owner(), amountNotVested));

        tokenGrant.startTime = 0;
        tokenGrant.amount = 0;
        tokenGrant.vestingDuration = 0;
        tokenGrant.daysClaimed = 0;
        tokenGrant.totalClaimed = 0;
        tokenGrant.recipient = address(0);

        emit GrantRemoved(recipient, amountVested, amountNotVested);
    }


    function claim(uint256 _grantId) external {
        uint256 daysVested;
        uint256 amountVested;
        (daysVested, amountVested) = calculateGrantClaim(_grantId);
        require(amountVested > 0, "amountVested is 0");

        Grant storage tokenGrant = tokenGrants[_grantId];
        tokenGrant.daysClaimed = tokenGrant.daysClaimed.add(daysVested);
        tokenGrant.totalClaimed = tokenGrant.totalClaimed.add(amountVested);
        
        require(token.transfer(tokenGrant.recipient, amountVested), "no tokens");
        emit GrantClaimed(tokenGrant.recipient, amountVested);
    }
}