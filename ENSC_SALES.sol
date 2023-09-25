// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ENSC_Sale is ERC20Capped, ReentrancyGuard {
    address payable public owner;
    ERC20 public ENSC_Token;
    ERC20 public USDC;
    ERC20 public USDT;
    uint256 public USD_RATE;
    address payable public ENSC_Wallet;
    address payable public admin;

    constructor(
        address payable _wallet,
        address _token,
        address _usdt,
        address _usdc,
        uint256 _usdRate
    ) ERC20("ENSC Sale", "ENSCS") ERC20Capped(10000000 * 10**18) {
        require(_wallet != address(0), "Invalid wallet address");
        owner = payable(msg.sender);
        ENSC_Wallet = _wallet;
        ENSC_Token = ERC20(_token);
        USDT = ERC20(_usdt);
        USDC = ERC20(_usdc);
        USD_RATE = _usdRate;
        admin = payable(msg.sender);
    }

    function updateUSDExchangeRate(uint256 _newRate) public onlyOwner {
        USD_RATE = _newRate;
    }

    function swapUSDCForENSC(uint256 _usdcAmount) public nonReentrant {
    require(_usdcAmount > 0, "Amount must be greater than 0");

    // Check if the contract is approved to spend USDC on behalf of the sender
    require(
        USDC.allowance(msg.sender, address(this)) >= _usdcAmount,
        "Insufficient USDC allowance"
    );

    // Transfer USDC from the user to this contract
    require(
        USDC.transferFrom(msg.sender, address(this), _usdcAmount),
        "Transfer of USDC failed"
    );

    // Calculate the amount of ENSC tokens to be allocated to the beneficiary
    uint256 enscAmount = _usdcAmount * USD_RATE;

    // Transfer ENSC tokens to the user
    require(
        ENSC_Token.transferFrom(owner, msg.sender, enscAmount),
        "Transfer of ENSC failed"
    );

    emit TokenPurchase(msg.sender, msg.sender, enscAmount);
    }

    function swapUSDTForENSC(uint256 _usdtAmount) public nonReentrant {
    require(_usdtAmount > 0, "Amount must be greater than 0");

    // Check if the contract is approved to spend USDT on behalf of the sender
    require(
        USDT.allowance(msg.sender, address(this)) >= _usdtAmount,
        "Insufficient USDT allowance"
    );

    // Transfer USDT from the user to this contract
    require(
        USDT.transferFrom(msg.sender, address(this), _usdtAmount),
        "Transfer of USDT failed"
    );

    // Calculate the amount of ENSC tokens to be allocated to the beneficiary
    uint256 enscAmount = _usdtAmount * USD_RATE;

    // Transfer ENSC tokens to the user
    require(
        ENSC_Token.transferFrom(owner, msg.sender, enscAmount),
        "Transfer of ENSC failed"
    );

    emit TokenPurchase(msg.sender, msg.sender, enscAmount);
}

    receive() external payable {
        // Handle any incoming Ether if necessary
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 tokens
    );
}
