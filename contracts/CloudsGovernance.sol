// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.13;

contract CloudsGovernance {
    mapping(uint256 => address) public tokens;
    uint256 nftPrice = 0.01 ether;

    function purchase(uint256 _tokenId) external payable {
        require(msg.value == nftPrice, "10 Clouds Governance Protocol costs 0.01 Eth");
        tokens[_tokenId] = msg.sender;
    }


    function getPrice() external view returns (uint256) {
        return nftPrice;
    }

    function available(uint256 _tokenId) external view returns (bool) {

        if (tokens[_tokenId] == address(0)) {
            return true;
        }
        return false;
    }
}
