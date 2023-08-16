// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ship/AstraOmniRiseSpaceship.sol";

contract AuctionSpaceship is Context,ReentrancyGuard,Ownable{
    using Counters for Counters.Counter;
    using Math for uint256;

    IERC20 public aorTokenContract;

    AstraOmniRiseSpaceship public shipContract;

    Counters.Counter public batchIdCounter;
    // Mapping from batch ID to AuctionBatch
    mapping(uint256 => Batch) public batches;

    struct Batch {
        uint256 saleStartTime;
        uint256 roundTime;
        //Quantity of space ships for sale
        uint256 saleQuantity;

        uint256 startingPrice;
        uint256 incrementPrice;
        //purchase limit per address
        uint256 purchaseLimit;

        uint256 roundStartTime;
        uint256 currentRound;

        AstraOmniRiseSpaceship.Metadata metadata;
    }
    enum Status {
        PENDING,
        ACTIVE,
        ENDED
    }

    //batchId => round => total bid count
    mapping(uint256 => mapping(uint256 => uint256)) public totalBidCount;
    //batchId => round => address => bid count
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public addressBidCount;

    //batchId => bidder => deposited tokens
    mapping(uint256 => mapping(address => uint256)) public depositedTokens;

    //batchId => bidder => claimed Ships
    mapping(uint256 => mapping(address => uint256)) public claimedShips;

    //batchId => withdrawn
    mapping(uint256 => bool) public withdrawn;

    //batchId => buyer => refunded
    mapping(uint256 => mapping(address => bool)) public refunded;



    constructor(IERC20 aorTokenContract_,AstraOmniRiseSpaceship shipContract_){
        aorTokenContract = aorTokenContract_;
        shipContract = shipContract_;
    }


    function newBatch(uint256 saleStartTime,uint256 roundTime,uint256 saleQuantity,uint256 startingPrice,uint256 incrementPrice,uint256 purchaseLimit,AstraOmniRiseSpaceship.Metadata memory metadata)  public onlyOwner{
        batchIdCounter.increment();
        uint256 batchId = batchIdCounter.current();
        Batch storage b = batches[batchId];
        b.saleStartTime = saleStartTime;
        b.roundStartTime = b.saleStartTime;
        b.currentRound = 1;
        b.roundTime = roundTime;
        b.saleQuantity = saleQuantity;
        b.startingPrice = startingPrice;
        b.incrementPrice = incrementPrice;
        b.purchaseLimit = purchaseLimit;
        b.metadata = metadata;
        require(bytes(metadata.image).length > 0 , "SpaceshipAuction: metadata error");
        require(bytes(metadata.animation_url).length > 0 , "SpaceshipAuction: metadata error");
        require(bytes(metadata.attr_name).length > 0 , "SpaceshipAuction: metadata error");
        require(bytes(metadata.attr_type).length > 0 , "SpaceshipAuction: metadata error");
        require(bytes(metadata.attr_rank).length > 0 , "SpaceshipAuction: metadata error");
        require(metadata.attr_hull > 0 , "SpaceshipAuction: metadata error");
        require(metadata.attr_energy > 0 , "SpaceshipAuction: metadata error");
        require(metadata.attr_speed > 0 , "SpaceshipAuction: metadata error");
    }


    function getStatus(uint256 batchId) view public returns (Status){
        Batch memory b = batches[batchId];
        uint256 currentTime = block.timestamp;
        if(b.saleStartTime > currentTime){
            return Status.PENDING;
        }

        uint256 bidCount = totalBidCount[batchId][b.currentRound];
        uint256 passedTime = currentTime - b.roundStartTime;

        if(passedTime > b.roundTime){
            if(bidCount < b.saleQuantity){
                return Status.ENDED;
            }
            return passedTime > b.roundTime * 2 ? Status.ENDED : Status.ACTIVE;
        }
        return Status.ACTIVE;
    }

    function getBidRound(uint256 batchId) view public returns (uint256){
        return batches[batchId].currentRound;
    }

    function getRoundPrice(uint256 batchId,uint256 round) view public returns (uint256){
        Batch memory b = batches[batchId];
        return b.startingPrice +  b.incrementPrice * (round -1);
    }

    function getPurchaseableQuantity(uint256 batchId,uint256 round,address buyer) view public returns (uint256){
        Batch memory b = batches[batchId];
        uint256 buyerBidedCount = addressBidCount[batchId][round][buyer];
        uint256 allBidedCount = totalBidCount[batchId][round];

        uint256 buyerRemaining = b.purchaseLimit - buyerBidedCount;
        uint256 allRemaining = b.saleQuantity - allBidedCount;

        return buyerRemaining.min(allRemaining);
    }

    event Bid(uint256 indexed batchId,address indexed buyer,uint256 indexed bidQuantity);

    function bid(uint256 batchId,uint256 bidQuantity) external nonReentrant {
        Status stat = getStatus(batchId);
        require(stat == Status.ACTIVE , "SpaceshipAuction: auction inactive");

        uint256 bidRound = getBidRound(batchId);

        //set bid count
        uint256 purchaseableQuantity = getPurchaseableQuantity(batchId,bidRound,_msgSender());
        require(purchaseableQuantity >=  bidQuantity, "SpaceshipAuction: exceeds the purchase limit");

        addressBidCount[batchId][bidRound][_msgSender()] += bidQuantity;
        totalBidCount[batchId][bidRound] += bidQuantity;

        // set round
        Batch memory bch = batches[batchId];
        if(bch.saleQuantity == totalBidCount[batchId][bidRound]){
            batches[batchId].currentRound += 1;
            batches[batchId].roundStartTime = block.timestamp;
        }
        // set deposited tokens
        uint256 roundPrice = getRoundPrice(batchId,bidRound);
        uint256 deposited = depositedTokens[batchId][_msgSender()];
        //needAmount
        uint256 needAmount = roundPrice * addressBidCount[batchId][bidRound][_msgSender()];
        if(needAmount > deposited){
            uint256 needPayAmount = needAmount - deposited;
            depositedTokens[batchId][_msgSender()] += needPayAmount;
            bool success = aorTokenContract.transferFrom(_msgSender(),address(this),needPayAmount);
            require(success, "SpaceshipAuction: failed to transfer AOR");
        }
        emit Bid(batchId,_msgSender(),bidQuantity);
    }

    function refundableTokens(uint256 batchId,address buyer) view public returns (uint256) {
        Status stat = getStatus(batchId);
        if(stat != Status.ENDED){
            return 0;
        }

        uint256 winningRound = getWinningRound(batchId);

        uint256 deposited = depositedTokens[batchId][buyer];
        if(winningRound == 0){
            return deposited;
        }
        return deposited - addressBidCount[batchId][winningRound][buyer] * getRoundPrice(batchId,winningRound);

    }

    function getWinningRound(uint256 batchId)view public returns (uint256) {
        Batch memory b = batches[batchId];
        uint256 round = b.currentRound;

        // endRound = winning round
        if(totalBidCount[batchId][round] == b.saleQuantity){
            return round;
        }
        return round - 1;
    }

    event Refund(uint256 indexed batchId,address indexed refundTo,uint256 indexed amount);

    function refund(uint256 batchId) external nonReentrant {
        Status stat = getStatus(batchId);
        require(stat == Status.ENDED, "SpaceshipAuction: auction not ended");

        require(!refunded[batchId][_msgSender()], "SpaceshipAuction: already refunded");

        uint256 amount = refundableTokens(batchId,_msgSender());
        require(amount > 0, "SpaceshipAuction: not eligible for refund");
        refunded[batchId][_msgSender()] = true;

        //transfer
        bool success = aorTokenContract.transfer(_msgSender(), amount);
        require(success, "SpaceshipAuction: failed to transfer AOR");

        emit Refund(batchId,_msgSender(),amount);
    }

    event ClaimShips(address indexed buyer,uint256 indexed batchId,uint256 indexed numberOfShips);

    function claimShips(uint256 batchId,uint256 numberOfShips) external nonReentrant {

        Status stat = getStatus(batchId);
        require(stat == Status.ENDED, "SpaceshipAuction: auction not ended");

        uint256 claimedQuantity = claimedShips[batchId][_msgSender()];

        uint256 winningRound = getWinningRound(batchId);

        require(winningRound > 0, "SpaceshipAuction: can not claim");

        uint256 claimableQuantity = addressBidCount[batchId][winningRound][_msgSender()];
        if(numberOfShips == 0){
            numberOfShips = claimableQuantity - claimedQuantity;
        }
        require(claimableQuantity >= numberOfShips + claimedQuantity, "SpaceshipAuction: the number of claims exceeds the limit");
        claimedShips[batchId][_msgSender()] += numberOfShips;

        //claimShips
        for (uint256 i = 1 ; i <= numberOfShips; i++) {
            shipContract.safeMint(_msgSender(),batches[batchId].metadata);
        }
        emit ClaimShips(_msgSender(),batchId,numberOfShips);

    }

    event Withdraw(address indexed operator,address indexed to,uint256 batchId,uint256 amount);

    function withdraw(uint256 batchId,address to) external nonReentrant onlyOwner {
        Status stat = getStatus(batchId);
        require(stat == Status.ENDED, "SpaceshipAuction: auction not ended");
        require(!withdrawn[batchId], "SpaceshipAuction: already withdrawn");
        withdrawn[batchId] = true;

        uint256 winningRound = getWinningRound(batchId);
        require(winningRound > 0, "SpaceshipAuction: auction ended with no sale");

        Batch memory b = batches[batchId];
        uint256 soldAmount  = b.saleQuantity * getRoundPrice(batchId,winningRound);
        //transfer
        bool success = aorTokenContract.transfer(to, soldAmount);
        require(success, "SpaceshipAuction: failed to transfer AOR");
        emit Withdraw(_msgSender(),to,batchId,soldAmount);
    }

}
