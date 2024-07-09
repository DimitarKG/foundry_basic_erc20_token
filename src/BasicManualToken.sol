// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract BasicManualToken {
    mapping(address => uint256) private s_balances;

    string name = "BasicManualToken";

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether; //100000000000000000000
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        uint256 startingBalance = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;
        assert(startingBalance == balanceOf(msg.sender) + balanceOf(_to));
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {}

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {}

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {}
}
