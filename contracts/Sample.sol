pragma solidity ^0.5.0;

contract Sample {
    string public name = "Moore ath John Yuur Gha";

    function set(string memory _name) public {
        name = _name;
    }

    function get() public view returns (string memory) {
        return name;
    }
}