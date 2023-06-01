// SPDX-License-Identifier: CC0-1.0

/// @title Pixel

/**
 * ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░██░░░░░▒▒▒▒▒██░░██░░░░░▒▒▒▒▒██░░░█
 * █░░░████████░░░░░▒▒▒▒▒██████░░░░░▒▒▒▒▒██░░░█
 * █░░░██░░░░██░░░░░▒▒▒▒▒██░░██░░░░░▒▒▒▒▒██░░░█
 * █░░░██░░░░██░░░░░▒▒▒▒▒██░░██░░░░░▒▒▒▒▒██░░░█
 * █░░░░░░░░░██████████████░░██████████████░░░█
 * █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
 * ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
 * ╔═══════════════════╗ ╔════════════════════╗
 * ║ https://nouns.wtf ║ ║ NO RIGHTS RESERVED ║
 * ╚═══════════════════╝ ╚════════════════════╝
 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@nouns-contracts/contracts/NounsToken.sol";

contract Pixel is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    IERC721Receiver
{
    uint256 public constant EXCHANGE_RATE = 1_000_000e18;

    NounsToken public nounsToken;

    address public delegatee = address(this);

    event Deposit(address indexed _from, uint256[] _tokenIds, uint256 _minted);
    event Withdraw(address indexed _from, uint256[] _tokenIds, uint256 _burned);
    event Swap(
        address indexed _from,
        uint256[] _fromTokenIds,
        uint256[] _forTokenIds
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _nounsToken,
        address _delegatee
    ) public initializer {
        __ERC20_init("Pixel", "PIXEL");
        __Ownable_init();
        __UUPSUpgradeable_init();

        nounsToken = NounsToken(_nounsToken);
        delegatee = _delegatee;
    }

    /**
     * @notice Deposit Nouns to mint $PIXEL
     * @param _tokenIds An array of tokenIds to be deposited
     */
    function deposit(uint256[] calldata _tokenIds) external {
        batchTransfer(msg.sender, address(this), _tokenIds);

        /**
         * @dev NounsToken automatically sets the delegate to
         *  this contract on deposit, so we need to redelegate
         *  it to the current delegatee if it's not this contract
         */
        if (delegatee != address(this)) {
            nounsToken.delegate(delegatee);
        }

        _mint(msg.sender, EXCHANGE_RATE * _tokenIds.length);

        emit Deposit(msg.sender, _tokenIds, EXCHANGE_RATE * _tokenIds.length);
    }

    /**
     * @notice Burn $PIXEL to withdraw Nouns
     * @param _tokenIds An array of tokenIds to be withdrawn
     */
    function withdraw(uint256[] calldata _tokenIds) external {
        _burn(msg.sender, EXCHANGE_RATE * _tokenIds.length);

        batchTransfer(address(this), msg.sender, _tokenIds);

        emit Withdraw(msg.sender, _tokenIds, EXCHANGE_RATE * _tokenIds.length);
    }

    /**
     * @notice Swap Nouns for other Nouns stored in the contract
     * @param _fromTokenIds An array of tokenIds to be deposited
     * @param _forTokenIds An array of tokenIds to be withdrawn
     */
    function swap(
        uint256[] calldata _fromTokenIds,
        uint256[] calldata _forTokenIds
    ) external {
        if (_fromTokenIds.length != _forTokenIds.length) {
            revert("_fromTokenIds and _forTokenIds must be the same length");
        }

        batchTransfer(msg.sender, address(this), _fromTokenIds);

        /**
         * @dev NounsToken automatically sets the delegate to
         *  this contract on deposit, so we need to redelegate
         *  it to the current delegatee if it's not this contract
         */
        if (delegatee != address(this)) {
            nounsToken.delegate(delegatee);
        }

        batchTransfer(address(this), msg.sender, _forTokenIds);

        emit Swap(msg.sender, _fromTokenIds, _forTokenIds);
    }

    /**
     * @notice Transfer multiple Nouns
     * @param _from The address to transfer from
     * @param _to The address to transfer to
     * @param _tokenIds An array of tokenIds to be transferred
     */
    function batchTransfer(
        address _from,
        address _to,
        uint256[] calldata _tokenIds
    ) internal {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            nounsToken.safeTransferFrom(_from, _to, _tokenIds[i]);
        }
    }

    /**
     * @notice Change the delegatee for Nouns stored in the contract
     * @param _delegatee The address of the new delegatee
     */
    function setDelegatee(address _delegatee) external onlyOwner {
        delegatee = _delegatee;
    }

    /**
     * @notice Authorize an upgrade to the contract from only the owner
     * @param newImplementation The new implementation
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

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
