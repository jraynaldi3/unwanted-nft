//SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @author Julius Raynaldi
* @notice smart contract inspired by cheese touch (ethhole.com/challenge);
* non-fungible token dapp for a token that no one wants to have, a cheese touch token. 
* only 1 token to be 'live' at a time. If there is no live token anyone can create one.
* users can transfer the live token to anyone else.
* If any user holds a live token for more than 24 hours then they can no longer transfer it,
* and the token should no longer be live. 
 */


contract UnwantedNFT is ERC721 {

    using Counters for Counters.Counter;

    event Started(uint tokenId,address startor);

    Counters.Counter tokenIds;
    
    uint endDate;
    uint duration;
    string public liveUri;
    string public deadUri;

    constructor(string memory _liveUri, string memory _deadUri) ERC721("Unwanted","UWT"){
        setLiveUri(_liveUri);
        setDeadUri(_deadUri);
    }

    mapping(uint => uint) tokenEndDate;

    function start() external {
        require (!isLive(), "Already Started!");
        uint newId = tokenIds.current();
        _mint(msg.sender, newId);
        endDate = block.timestamp + duration;
        tokenEndDate[newId] = endDate;
        tokenIds.increment();
        emit Started(newId, msg.sender);
    }

    function isLive() internal view returns(bool){
        if (block.timestamp > endDate) {
            return false;
        }
        return true;
    }

    function isTokenLive(uint tokenId) internal view returns(bool){
        if(tokenEndDate[tokenId] > block.timestamp){
            return true;
        }
        return false;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(isTokenLive(tokenId), "Already Over");
        super.transferFrom(from,to,tokenId);
        endDate = block.timestamp + duration;
        tokenEndDate[tokenId] = endDate;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(isTokenLive(tokenId), "Already Over");
        super.safeTransferFrom(from,to,tokenId,_data);
        endDate = block.timestamp + duration;
        tokenEndDate[tokenId] = endDate;
    }

    function setDuration(uint _duration) external {
        duration = _duration;
    }

    function tokenURI(uint tokenId) public view override returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if (isTokenLive(tokenId)){
            return liveUri;
        } else {
            return deadUri;
        } 
    }

    function setLiveUri(string memory _liveUri) internal {
        liveUri = _liveUri;
    }

    function setDeadUri(string memory _deadUri) internal {
        deadUri = _deadUri;
    }
}
