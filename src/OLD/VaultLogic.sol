// SPDX-License-Identifier: CC0-1.0

/// @title Vault Logic

/**
 * ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░██▒▒▒▒▒░░░░░██░░██▒▒▒▒▒░░░░░██░░░█
 * █░░░████████▒▒▒▒▒░░░░░██████▒▒▒▒▒░░░░░██░░░█
 * █░░░██░░░░██▒▒▒▒▒░░░░░██░░██▒▒▒▒▒░░░░░██░░░█
 * █░░░██░░░░██▒▒▒▒▒░░░░░██░░██▒▒▒▒▒░░░░░██░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
 * ╔═══════════════════╗ ╔════════════════════╗
 * ║ https://nouns.wtf ║ ║ NO RIGHTS RESERVED ║
 * ╚═══════════════════╝ ╚════════════════════╝
 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@nouns-contracts/contracts/governance/NounsDAOLogicV2.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@nouns-contracts/contracts/NounsToken.sol";
import "./Pixel.sol";

contract VaultLogic is IERC721Receiver, Initializable {
    Pixel public pixels;
    NounsToken public nounsToken;
    NounsDAOLogicV2 public nounsDAO;

    function initialize(
        address _pixel,
        address _nounsToken,
        address payable _nounsDAO
    ) public initializer {
        pixels = Pixel(_pixel);

        nounsToken = NounsToken(_nounsToken);
        nounsToken.setApprovalForAll(_pixel, true);

        nounsDAO = NounsDAOLogicV2(_nounsDAO);
    }

    function vote(uint256 _proposalId, uint8 _type) public {
        nounsDAO.castVote(_proposalId, _type);
    }

    function voteWithReason(
        uint256 _proposalId,
        uint8 _type,
        string calldata _reason
    ) public {
        nounsDAO.castVoteWithReason(_proposalId, _type, _reason);
    }

    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     *  after a `transfer`. This function MAY throw to revert and reject the
     *  transfer. Return of other than the magic value MUST result in the
     *  transaction being reverted.
     *  Note: the contract address is always the message sender.
     * @param _operator The address which called `safeTransferFrom` function
     * @param _from The address which previously owned the token
     * @param _tokenId The NFT identifier which is being transferred
     * @param _data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     *  unless throwing
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
