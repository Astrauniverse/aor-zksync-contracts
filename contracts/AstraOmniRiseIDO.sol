// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AstraOmniRiseIDO is Context,ReentrancyGuard,Ownable{

    ERC20 public usdTokenContract;

    ERC20 public aorTokenContract;

    uint256 public salePrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;

    // minimum purchase amount per address
    uint256 public minDeposit;

    // maximum purchase amount per address
    uint256 public maxDeposit;

    mapping(address => uint256) public depositOf;

    uint256 public totalDeposit;


    //Refund
    mapping(address => uint256) public refundOf;

    //Goal amount for capital raising
    uint256 public goalAmount;

    //Claim AOR time interval
    uint256 public claimInterval = 30*24*60*60;

    mapping(address => mapping(uint256 => uint256)) public claimRecordOf;


    constructor(ERC20 usdTokenContract_,ERC20 aorTokenContract_,uint256 saleStartTime_,uint256 saleEndTime_,uint256 minDeposit_,uint256 maxDeposit_,uint256 goalAmount_){
        usdTokenContract = usdTokenContract_;
        aorTokenContract = aorTokenContract_;
        salePrice = 15 * 10 ** (usdTokenContract.decimals() -3);
        saleStartTime = saleStartTime_;
        saleEndTime = saleEndTime_;
        minDeposit = minDeposit_* 10 ** usdTokenContract.decimals();
        maxDeposit = maxDeposit_* 10 ** usdTokenContract.decimals();
        goalAmount = goalAmount_* 10 ** usdTokenContract.decimals();
    }

    event Deposit(address indexed from,uint256 indexed quantity);

    function deposit(uint256 quantity) external nonReentrant {

        require(block.timestamp >= saleStartTime, "AstraOmniRiseIDO: not yet on sale");
        require(block.timestamp < saleEndTime, "AstraOmniRiseIDO: sale has ended");

        uint256 depositedQuantity = depositOf[_msgSender()];
        uint256 allDeposit = depositedQuantity + quantity;
        require(allDeposit >= minDeposit && allDeposit <= maxDeposit, "AstraOmniRiseIDO: exceeds the purchase limit");

        depositOf[_msgSender()] += quantity;
        totalDeposit += quantity;


        //transfer
        bool success = usdTokenContract.transferFrom(_msgSender(),address(this),quantity);
        require(success, "AstraOmniRiseIDO: failed to transfer USD");

        emit Deposit(_msgSender(),quantity);
    }

    event Withdraw(ERC20 indexed token,address indexed to,uint256 quantity);

    function withdraw(ERC20 token,address to,uint256 quantity) external nonReentrant onlyOwner {
        //transfer
        bool success = token.transfer(to, quantity);
        require(success, "AstraOmniRiseIDO: failed to transfer token");
        emit Withdraw(token,to,quantity);
    }

    event Refund(address indexed to,uint256 indexed refundAmount);

    function refund() external nonReentrant {
        require(block.timestamp > saleEndTime, "AstraOmniRiseIDO: sale not yet ended");
        require(totalDeposit > goalAmount, "AstraOmniRiseIDO: goal not exceeded");
        require(refundOf[_msgSender()] == 0, "AstraOmniRiseIDO: already refunded");

        uint256 depositedAmount = depositOf[_msgSender()];
        require(depositedAmount > 0, "AstraOmniRiseIDO: sender deposited 0 amount");


        uint256 refundAmount = getRefundAmount(_msgSender());

        require(refundAmount > 0, "AstraOmniRiseIDO: refund amount must be greater than 0");

        refundOf[_msgSender()] = refundAmount;

        //transfer
        bool success = usdTokenContract.transfer(_msgSender(), refundAmount);
        require(success, "AstraOmniRiseIDO: failed to transfer USD");
        emit Refund(_msgSender(),refundAmount);
    }

    function getClaimStartTime(uint8 term) view public returns (uint256){
        return saleEndTime + claimInterval * (term -1);
    }

    function getRefundAmount(address addr) view public returns (uint256){
        if(totalDeposit <= goalAmount){
            return 0;
        }
        uint256 depositedAmount = depositOf[addr];
        if(depositedAmount == 0){
            return 0;
        }

        uint256 remaining = totalDeposit - goalAmount;
        return remaining * depositedAmount / totalDeposit;
    }

    function getClaimAmount(address addr) view public returns (uint256){
        uint256 depositedAmount = depositOf[addr];
        if(depositedAmount == 0){
            return 0;
        }
        uint256  refundedAmount = refundOf[addr];
        if(refundedAmount == 0){
            uint256 refundableAmount = getRefundAmount(addr);
            depositedAmount -= refundableAmount;
        }else{
            depositedAmount -= refundedAmount;
        }
        uint256 perTerm = depositedAmount / 10;
        return perTerm * 10 ** aorTokenContract.decimals() / salePrice;
    }



    event Claim(address indexed recipient,uint256 indexed claimAmount);

    function claim(uint8 term) external nonReentrant {
        require(term > 0 && term <= 10, "AstraOmniRiseIDO: term error");
        require(claimRecordOf[_msgSender()][term] == 0, "AstraOmniRiseIDO: term already claimed");

        uint256 claimStartTime = getClaimStartTime(term);
        require(block.timestamp > claimStartTime, "AstraOmniRiseIDO: claim term not started");

        uint256 depositedAmount = depositOf[_msgSender()];
        require(depositedAmount > 0, "AstraOmniRiseIDO: sender deposited 0 amount");

        uint256 claimAmount = getClaimAmount(_msgSender());

        require(claimAmount > 0, "AstraOmniRiseIDO: claim amount must be greater than 0");

        claimRecordOf[_msgSender()][term] = claimAmount;


        //transfer
        bool success = aorTokenContract.transfer(_msgSender(), claimAmount);
        require(success, "AstraOmniRiseIDO: failed to transfer AOR");
        emit Claim(_msgSender(),claimAmount);
    }


}
