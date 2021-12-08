// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC1155.sol";
//import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "./ERC1155Burnable.sol";
import "./Strings.sol";
import "./IERC20.sol";
import "./IERC1155Receiver.sol";
import "./ILoserUyangTreasury.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract ERC1155Tradable is ERC1155, ERC1155Burnable, Ownable, IERC1155Receiver, IERC721Receiver {
    using Strings for string;

    struct Proposal {
        address creator;
        uint256 id;
        string uri;
        uint256 support;
        uint256 oppose;
    }

    address daoToken;
    address lowbToken;

    uint256 private _currentTokenID = 0;
    uint256 public nftTypeSum = 0;
    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => string) public idToUri;

    mapping(uint256 => Proposal) public idToProposal;
    mapping(address => mapping(uint => uint)) public userSupportProposal;
    mapping(address => mapping(uint => uint)) public userOpposeProposal;
    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    bool private isCreating = false;

    /**
     * @dev Require msg.sender to be the creator of the token id
     */
    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender, "ERC1155Tradable#creatorOnly: ONLY_CREATOR_ALLOWED");
        _;
    }

    /**
     * @dev Require msg.sender to own more than 0 of the token id
     */
    modifier ownersOnly(uint256 _id) {
        require(
            balanceOf(msg.sender, _id) > 0,
            "ERC1155Tradable#ownersOnly: ONLY_OWNERS_ALLOWED"
        );
        _;
    }

    event PublishProposal(uint256 id, address creator, uint256 timestamp);
    event SupportProposal(address sender, uint256 id, uint256 amount);
    event OpposeProposal(address sender, uint256 id, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        address _daoToken,
        address _lowbToken
    ) ERC1155("") {
        name = _name;
        symbol = _symbol;
        daoToken = _daoToken;
        lowbToken = _lowbToken;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(_exists(_id), "ERC721Tradable#uri: NONEXISTENT_TOKEN");
        return idToUri[_id];
    }

    /**
     * @dev Returns the total quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @return amount of token in existence
     */
    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function publishProposal(
        string calldata  _uri
    ) external returns (uint256) {
        require(!isCreating, "other article is creating");
        require(bytes(_uri).length > 0, "uri is empty");
        isCreating = true;

        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;

        if (bytes(_uri).length > 0) {
            emit URI(_uri, _id);
        }
        idToUri[_id] = _uri;
        _mint(address(this), _id, 1, "0x00");
        idToProposal[_id] = Proposal(msg.sender, _id, _uri, 0, 0);

        tokenSupply[_id] = 1;
        nftTypeSum++;
        isCreating = false;
        emit PublishProposal(_id, msg.sender, block.timestamp);
        return _id;
    }



    // support proposal
    function supportProposal(uint256 _id)
        public
        returns (bool)
    {
        require(userSupportProposal[msg.sender][_id] == 0, "you have support this Proposal");
        require(userOpposeProposal[msg.sender][_id] == 0, "you have oppose Proposal");
        IERC20 loserDaoToken= IERC20(daoToken);
        uint256 daoTokenBalance = loserDaoToken.balanceOf(msg.sender);
        require(daoTokenBalance > 0, "you do not have LoserDaoToken");
        userSupportProposal[msg.sender][_id] = daoTokenBalance;
        idToProposal[_id].support += daoTokenBalance;
        emit SupportProposal(msg.sender, _id, daoTokenBalance);
        return true;
    }

    // oppose proposal
    function opposeProposal(uint256 _id)
        public
        returns (bool)
    {
        require(userSupportProposal[msg.sender][_id] == 0, "you have support this Proposal");
        require(userOpposeProposal[msg.sender][_id] == 0, "you have oppose Proposal");
        IERC20 loserDaoToken = IERC20(daoToken);
        uint256 daoTokenBalance = loserDaoToken.balanceOf(msg.sender);
        require(daoTokenBalance > 0, "you do not have LoserDaoToken");
        userOpposeProposal[msg.sender][_id] = daoTokenBalance;
        idToProposal[_id].oppose += daoTokenBalance;
        emit OpposeProposal(msg.sender, _id, daoTokenBalance);
        return true;
    }

    // /**
    //  * never mint
    //  * @dev Mints some amount of tokens to an address
    //  * @param _to          Address of the future owner of the token
    //  * @param _id          Token ID to mint
    //  * @param _quantity    Amount of tokens to mint
    //  * @param _data        Data to pass if receiver is contract
    //  */
    // function mint(
    //     address _to,
    //     uint256 _id,
    //     uint256 _quantity,
    //     bytes memory _data
    // ) public creatorOnly(_id) {
    //     _mint(_to, _id, _quantity, _data);
    //     tokenSupply[_id] = tokenSupply[_id] + _quantity;
    // }

    // /**
    //  * never mint
    //  * @dev Mint tokens for each id in _ids
    //  * @param _to          The address to mint tokens to
    //  * @param _ids         Array of ids to mint
    //  * @param _quantities  Array of amounts of tokens to mint per id
    //  * @param _data        Data to pass if receiver is contract
    //  */
    // function batchMint(
    //     address _to,
    //     uint256[] memory _ids,
    //     uint256[] memory _quantities,
    //     bytes memory _data
    // ) public {
    //     for (uint256 i = 0; i < _ids.length; i++) {
    //         uint256 _id = _ids[i];
    //         require(
    //             creators[_id] == msg.sender,
    //             "ERC1155Tradable#batchMint: ONLY_CREATOR_ALLOWED"
    //         );
    //         uint256 quantity = _quantities[i];
    //         tokenSupply[_id] = tokenSupply[_id] + quantity;
    //     }
    //     _mintBatch(_to, _ids, _quantities, _data);
    // }


    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        // ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        // if (address(proxyRegistry.proxies(_owner)) == _operator) {
        //     return true;
        // }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }

    /**
     * @dev Change the creator address for given token
     * @param _to   Address of the new creator
     * @param _id  Token IDs to change creator of
     */
    function _setCreator(address _to, uint256 _id) internal creatorOnly(_id) {
        creators[_id] = _to;
    }

    /**
     * @dev Returns whether the specified token exists by checking to see if it has a creator
     * @param _id uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenID
     * @return uint256 for the next token ID
     */
    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID + 1;
    }

    /**
     * @dev increments the value of _currentTokenID
     */
    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {

    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) public override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) public override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}
