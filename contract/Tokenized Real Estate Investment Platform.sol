// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Tokenized Real Estate Investment Platform
 * @dev Allows property owners to tokenize real estate and investors to buy property tokens.
 */
contract TokenizedRealEstate {
    address public owner;
    uint256 public propertyCount;

    struct Property {
        uint256 id;
        string name;
        uint256 totalTokens;
        uint256 tokenPrice;
        uint256 tokensAvailable;
        mapping(address => uint256) investors;
    }

    mapping(uint256 => Property) public properties;

    event PropertyListed(uint256 id, string name, uint256 totalTokens, uint256 tokenPrice);
    event TokensPurchased(uint256 propertyId, address investor, uint256 amount);
    event TokensTransferred(uint256 propertyId, address from, address to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev List a new property for tokenized investment.
     * @param _name Property name
     * @param _totalTokens Total number of tokens representing the property
     * @param _tokenPrice Price per token in wei
     */
    function listProperty(string memory _name, uint256 _totalTokens, uint256 _tokenPrice) external onlyOwner {
        propertyCount++;
        Property storage prop = properties[propertyCount];
        prop.id = propertyCount;
        prop.name = _name;
        prop.totalTokens = _totalTokens;
        prop.tokenPrice = _tokenPrice;
        prop.tokensAvailable = _totalTokens;

        emit PropertyListed(propertyCount, _name, _totalTokens, _tokenPrice);
    }

    /**
     * @dev Allows an investor to buy property tokens.
     * @param _propertyId The ID of the property
     * @param _amount Number of tokens to buy
     */
    function buyTokens(uint256 _propertyId, uint256 _amount) external payable {
        Property storage prop = properties[_propertyId];
        require(_amount > 0, "Invalid token amount");
        require(prop.tokensAvailable >= _amount, "Not enough tokens available");
        require(msg.value == _amount * prop.tokenPrice, "Incorrect ETH sent");

        prop.tokensAvailable -= _amount;
        prop.investors[msg.sender] += _amount;

        emit TokensPurchased(_propertyId, msg.sender, _amount);
    }

    /**
     * @dev Transfer property tokens to another investor.
     * @param _propertyId The ID of the property
     * @param _to Recipient address
     * @param _amount Number of tokens to transfer
     */
    function transferTokens(uint256 _propertyId, address _to, uint256 _amount) external {
        Property storage prop = properties[_propertyId];
        require(prop.investors[msg.sender] >= _amount, "Insufficient balance");

        prop.investors[msg.sender] -= _amount;
        prop.investors[_to] += _amount;

        emit TokensTransferred(_propertyId, msg.sender, _to, _amount);
    }
}

