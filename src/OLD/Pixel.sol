// SPDX-License-Identifier: CC0-1.0

/// @title Pixel

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

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@nouns-contracts/contracts/NounsToken.sol";
import "./VaultLogic.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract Pixel is ERC20, Ownable {
    uint256 public constant EXCHANGE_RATE = 1_000_000e18;

    NounsToken public nounsToken;

    UpgradeableBeacon immutable beacon;
    address public vaultLogic;

    mapping(uint256 => address) public nouns;
    address[] public openVaults;

    constructor(
        address _nounsToken,
        address _vaultLogic,
        uint256 _initialVaults
    ) ERC20("Pixel", "PIXEL") {
        nounsToken = NounsToken(_nounsToken);
        beacon = new UpgradeableBeacon(_vaultLogic);
        vaultLogic = _vaultLogic;

        if (_initialVaults > 0) {
            createVaults(_initialVaults);
        }
    }

    event Deposit(address indexed _from, uint256[] _tokenIds, uint256 _minted);
    event Withdraw(address indexed _from, uint256[] _tokenIds, uint256 _burned);
    event Swap(
        address indexed _from,
        uint256[] _fromTokenIds,
        uint256[] _forTokenIds
    );

    /**
     * @notice Deposit Nouns to mint $PIXEL
     * @param _tokenIds An array of tokenIds to be deposited
     */
    function deposit(uint256[] calldata _tokenIds) external {
        uint256 _openVaultCount = openVaults.length;

        if (_tokenIds.length > _openVaultCount) {
            uint256 newVaultCount = _tokenIds.length - _openVaultCount;
            createVaults(newVaultCount);
            _openVaultCount += newVaultCount;
        }

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            address lastVault = openVaults[_openVaultCount - 1 - i];

            nounsToken.transferFrom(msg.sender, lastVault, _tokenIds[i]);

            nouns[_tokenIds[i]] = lastVault;

            openVaults.pop();
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

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            address vault = nouns[_tokenIds[i]];

            nounsToken.transferFrom(vault, msg.sender, _tokenIds[i]);

            openVaults.push(vault);
            nouns[_tokenIds[i]] = address(0);
        }

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

        for (uint256 i = 0; i < _forTokenIds.length; i++) {
            address vault = nouns[_forTokenIds[i]];

            if (vault == address(0)) {
                revert(
                    "The Noun that was requested is not stored in the contract"
                );
            }

            nounsToken.transferFrom(vault, msg.sender, _forTokenIds[i]);
            nouns[_forTokenIds[i]] = address(0);

            nounsToken.transferFrom(msg.sender, vault, _fromTokenIds[i]);
            nouns[_fromTokenIds[i]] = vault;
        }

        emit Swap(msg.sender, _fromTokenIds, _forTokenIds);
    }

    /**
     * @notice Create new vault(s) to store Nouns
     * @param _count The amount of vaults to be created
     */
    function createVaults(uint256 _count) internal {
        if (_count <= 0) {
            revert("At least one vault must be created");
        }

        for (uint256 i = 0; i < _count; i++) {
            BeaconProxy vault = new BeaconProxy(
                address(beacon),
                abi.encodeWithSelector(
                    VaultLogic.initialize.selector,
                    address(nounsToken)
                )
            );

            openVaults.push(address(vault));
        }
    }

    /**
     * @notice Update the vaultLogic to a new implementation
     * @param _vaultLogic The address of the new vaultLogic implementation
     */
    function update(address _vaultLogic) public onlyOwner {
        beacon.upgradeTo(_vaultLogic);
        vaultLogic = _vaultLogic;
    }

    /**
     * @notice Retrieves the current implementation of the vaultLogic
     */
    function implementation() public view returns (address) {
        return beacon.implementation();
    }
}
