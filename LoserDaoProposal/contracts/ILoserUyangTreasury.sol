// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILoserUyangTreasury {
    function sendAllTreasuryBalance(uint256 balance) external;

    function sendTreasuryBalance(uint256 id_, uint256 balance_) external;

    function sendOwnerBalance(uint256 balance_) external; 

    function sendAddressBalance(address address_,  uint256 balance_) external;

    function sendPunkBalance(uint256 balance_) external ;
}
