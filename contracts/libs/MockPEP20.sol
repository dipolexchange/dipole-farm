pragma solidity 0.6.12;

import "@dipoleswap/dipole-swap-lib/contracts/token/PEP20/PEP20.sol";

contract MockPEP20 is PEP20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) public PEP20(name, symbol) {
        _mint(msg.sender, supply);
    }

    function mockMint(address to, uint amount) public {
        _mint(to, amount);
    }
}
