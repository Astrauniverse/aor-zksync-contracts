//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Greeter  {
    string private greeting;

    constructor(string memory _greeting) {
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    event LogTimestamp(uint256 indexed time);

    function logTimestamp() public  {
        emit LogTimestamp(block.timestamp);
    }

    function blockChainId() public view returns (uint256){
        return block.chainid;
    }

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }
    function checkInWhitelist(bytes32 whitelistRoot,bytes32[] calldata proof,address addr,uint8 whitelistType) pure public returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(addr,whitelistType));
        bool verified = MerkleProof.verify(proof, whitelistRoot, leaf);
        return verified;
    }
}
