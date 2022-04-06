// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


interface ICloudMint {

    function getPrice() external view returns (uint256);
    function available(uint256 _tokenId) external view returns (bool);

    function purchase(uint256 _tokenId) external payable;
}


interface ICloudNFT {

    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}

contract CloudsProtocol is Ownable {
    ICloudMint mintNFT;
    ICloudNFT cloudsGovernance;

    struct Proposal {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 approve;
        uint256 deny;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    enum Vote {
        YEP,
        NAH
    }


    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    modifier nftHolderOnly() {
        require(cloudsGovernance.balanceOf(msg.sender) > 0, "NOT_A_TEN_CLOUDS_MEMBER");
        _;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "DEADLINE_EXCEEDED"
        );
        _;
    }


    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "DEADLINE_NOT_EXCEEDED"
        );
        require(
            proposals[proposalIndex].executed == false,
            "PROPOSAL_ALREADY_APPROVED"
        );
        _;
    }

    constructor(address _mintNFT, address _cloudsGovernance) payable {
        mintNFT = ICloudMint(_mintNFT);
        cloudsGovernance = ICloudNFT(_cloudsGovernance);
    }


    function createProposal(uint256 _nftTokenId)
        external
        nftHolderOnly
        returns (uint256)
    {
        require(mintNFT.available(_nftTokenId), "TEN_CLOUDS_NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 120 minutes;

        numProposals++;

        return numProposals - 1;
    }


    function voteOnProposal(uint256 proposalIndex, Vote vote)
        external
        nftHolderOnly
        activeProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = cloudsGovernance.balanceOf(msg.sender);
        uint256 numVotes = 0;


        for (uint256 i = 0; i < voterNFTBalance; i++) {
            console.log(cloudsGovernance.tokenOfOwnerByIndex(msg.sender, i));
            uint256 tokenId = cloudsGovernance.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false) {
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }
        require(numVotes > 0, "ALREADY_VOTED");

        if (vote == Vote.YEP) {
            proposal.approve += numVotes;
        } else {
            proposal.deny += numVotes;
        }
    }


    function executeProposal(uint256 proposalIndex)
        external
        nftHolderOnly
        inactiveProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];


        if (proposal.approve > proposal.deny) {
            uint256 nftPrice = mintNFT.getPrice();
            require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
            mintNFT.purchase{value: nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}
