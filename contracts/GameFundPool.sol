// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./ship/AstraOmniRiseSpaceship.sol";


contract GameFundPool is ReentrancyGuard,AccessControlEnumerable,IERC721Receiver{

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    AstraOmniRiseSpaceship public spaceshipContract;

    IERC20 public aorTokenContract;

    constructor(AstraOmniRiseSpaceship spaceshipContract_,IERC20 aorTokenContract_){
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(OPERATOR_ROLE, _msgSender());
        spaceshipContract = spaceshipContract_;
        aorTokenContract = aorTokenContract_;
    }

    // tokenId => owner
    mapping(uint256 => address) public ownerOf;

    // withdrawId => withdrawn
    mapping(uint256 => bool) public withdrawn;

    // claimId => claimed
    mapping(uint256 => bool) public claimed;


    function claimHash(uint256 claimId,uint256 quantity,address recipient) public view returns (bytes32) {
        bytes4 selector = this.claimHash.selector;
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(block.chainid,address(this),selector,claimId,quantity,recipient)));
    }

    event ClaimAOR(uint256 indexed claimId, uint256 indexed quantity);

    function claimAOR(uint256 claimId,uint256 quantity,bytes memory signature) external nonReentrant {
        require(!claimed[claimId], "GameFundPool: already claimed");

        address recipient = _msgSender();

        bytes32 hashStr = claimHash(claimId,quantity,recipient);
        require(verify(hashStr,signature), "GameFundPool: invalid signature");

        claimed[claimId] = true;

        //transfer
        bool success = aorTokenContract.transfer(recipient, quantity);
        require(success, "GameFundPool: failed to transfer AOR");

        emit ClaimAOR(claimId,quantity);
    }

    function verify(bytes32 digest, bytes memory signature) public view returns (bool) {
        address signer = ECDSA.recover(digest, signature);
        return hasRole(OPERATOR_ROLE,signer);
    }
    function withdrawHash(uint256 withdrawId,address recipient,uint256 tokenId) public view returns (bytes32) {
        bytes4 selector = this.withdrawHash.selector;
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(block.chainid,address(this),selector,withdrawId,recipient,tokenId)));
    }
    event WithdrawSpaceship(address indexed recipient,uint256 indexed tokenId);

    function withdrawSpaceship(uint256 withdrawId,uint256 tokenId,bytes memory signature) external nonReentrant {
        require(!withdrawn[withdrawId], "GameFundPool: already withdrawn");

        address recipient = _msgSender();
        require(ownerOf[tokenId] == recipient, "GameFundPool: not the owner");

        bytes32 hashStr = withdrawHash(withdrawId,recipient,tokenId);
        require(verify(hashStr,signature), "GameFundPool: invalid signature");

        delete ownerOf[tokenId];
        withdrawn[withdrawId] = true;

        spaceshipContract.safeTransferFrom(address(this),recipient,tokenId);

        emit WithdrawSpaceship(recipient,tokenId);
    }


    event SpaceshipDeposit(address indexed operator, address indexed from, uint256 indexed tokenId, bytes data);

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual nonReentrant override returns (bytes4)  {
        require(_msgSender() == address(spaceshipContract), "GameFundPool: sender must equals spaceshipContract");
        ownerOf[tokenId] = from;
        emit SpaceshipDeposit(operator, from, tokenId, data);
        return this.onERC721Received.selector;
    }



    event WithdrawERC20(IERC20 indexed token,address indexed to,uint256 quantity);

    function withdrawERC20(IERC20 token,address to,uint256 quantity) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        //transfer
        bool success = token.transfer(to, quantity);
        require(success, "GameFundPool: failed to transfer token");
        emit WithdrawERC20(token,to,quantity);
    }


}