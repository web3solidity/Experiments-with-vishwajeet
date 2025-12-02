// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DigitalSketchMarketplace is Ownable, ReentrancyGuard {

    // --- Custom Errors ---
    error InvalidWallet();
    error SketchNotFound();
    error CannotBuyOwnSketch();
    error IncorrectPayment();
    error ArtistPaymentFailed();
    error PlatformPaymentFailed();
    error FeeTooHigh();
    error RenounceDisabled();

    struct Sketch {
        address artist;
        uint256 price; // in wei
        string ipfsHash; // off-chain file reference
    }

    mapping(uint256 => Sketch) public sketches;
    uint256 public sketchCount;

    uint256 public platformFeePercent = 5; // 5%
    address payable public platformWallet;

    event SketchAdded(
        uint256 indexed id,
        address indexed artist,
        uint256 price,
        string ipfsHash
    );
    event SketchPurchased(
        uint256 indexed id,
        address indexed buyer,
        uint256 price
    );

    constructor(address payable _platformWallet) Ownable(msg.sender) {
        if(_platformWallet == address(0)) revert InvalidWallet();
        platformWallet = _platformWallet;
    }

    function addSketch(uint256 _price, string memory _ipfsHash) external {
        if(_price == 0)revert IncorrectPayment();
        if(bytes(_ipfsHash).length == 0) revert IncorrectPayment();

          unchecked {
            sketchCount++;
        }
        
        sketches[sketchCount] = Sketch(msg.sender, _price, _ipfsHash);

        emit SketchAdded(sketchCount, msg.sender, _price, _ipfsHash);
    }

    function purchaseSketch(uint256 _id) external payable nonReentrant {
        Sketch memory sketch = sketches[_id];
        if(_id==0 || _id > sketchCount) revert SketchNotFound();
        if(msg.sender == sketch.artist) revert CannotBuyOwnSketch();
        if(msg.value != sketch.price)revert IncorrectPayment();

        uint256 platformFee = (msg.value * platformFeePercent) / 100;
        uint256 artistPayout = msg.value - platformFee;

        // Transfer funds
        (bool sentArtist, ) = payable(sketch.artist).call{value: artistPayout}("");
        if(!sentArtist) revert  ArtistPaymentFailed();

        (bool sentPlatform, ) = platformWallet.call{value: platformFee}("");
        if(!sentPlatform) revert PlatformPaymentFailed();

        emit SketchPurchased(_id, msg.sender, msg.value);
    }

    function setPlatformFee(uint256 _feePercent) external onlyOwner {
        if(_feePercent >= 21)revert FeeTooHigh();
        platformFeePercent = _feePercent;
    }

    function setPlatformWallet(address payable _wallet) external onlyOwner {
        if(_wallet == address(0))revert InvalidWallet();
        platformWallet = _wallet;
    }
    function renounceOwnership() public pure override {
        revert RenounceDisabled();
    }
}
