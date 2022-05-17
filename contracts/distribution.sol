pragma solidity 0.6.12;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@dipoleswap/dipole-swap-lib/contracts/token/PEP20/IPEP20.sol";
import "@dipoleswap/dipole-swap-lib/contracts/token/PEP20/SafePEP20.sol";

contract Distribution is Ownable {
    using SafeMath for uint256;
    using SafePEP20 for IPEP20;

    // Info of each allocation.
    struct AllocInfo {
        address allocAddr;
        uint256 allocPoint;       // How many allocation points assigned to this pool. Dipo to distribute per block.
    }

    AllocInfo[] public allocInfo;
    // total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    event Add(address indexed allocAddr, uint256 indexed aid, uint256 allocPoint);
    event Allocation(address indexed allocToken, uint256 amount);
    event EmergencyWithdraw(address indexed addr, address indexed allocToken, uint256 amount);

    constructor(
        address _governance,
        address _devOps,
        address _otherExpenses
    ) public {
        allocInfo.push(AllocInfo({
            allocAddr: _governance,
            allocPoint: 800
        }));
        allocInfo.push(AllocInfo({
            allocAddr: _devOps,
            allocPoint: 100
        }));
        allocInfo.push(AllocInfo({
            allocAddr: _otherExpenses,
            allocPoint: 100
        }));
        totalAllocPoint = 1000;
    }

    function allocLength() external view returns (uint256) {
        return allocInfo.length;
    }

    // Add a new address to the alloc. Can only be called by the owner.
    function add(uint256 _allocPoint, address _addr) public onlyOwner {
        require(_allocPoint != 0, "Distribution::add: Init allocPoint can not be zero");
        require(_addr != address(0), "Distribution::add: cannot add zero address");
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        allocInfo.push(AllocInfo({
            allocAddr: _addr,
            allocPoint: _allocPoint
        }));
        emit Add(_addr, allocInfo.length - 1, _allocPoint);
    }

    // Update the given alloc's allocToken allocation point. Can only be called by the owner.
    function set(uint256 _aid, uint256 _allocPoint) public onlyOwner {
        require(_aid < allocInfo.length, "Distribution::set: params aid array out of bounds");
        uint256 prevAllocPoint = allocInfo[_aid].allocPoint;
        if (prevAllocPoint != _allocPoint) {
            allocInfo[_aid].allocPoint = _allocPoint;
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
    }

    // allocate token to allocInfo addresses.
    function allocation(IPEP20 allocToken) public onlyOwner {
        uint256 allocTokenBal = allocToken.balanceOf(address(this));
        require ( allocTokenBal > 0, "alloc balance is zero");
        uint256 length = allocInfo.length;
        for (uint256 aid = 0; aid < length; ++aid) {
            uint256 allocAmount = allocTokenBal.mul(allocInfo[aid].allocPoint).div(totalAllocPoint);
            if (allocAmount > 0) {
                safeAllocTokenTransfer(allocToken, allocInfo[aid].allocAddr, allocAmount);
            }
        }
        emit Allocation(address(allocToken), allocTokenBal);
    }

    // Withdraw allocToken. EMERGENCY ONLY.
    function emergencyWithdraw(IPEP20 allocToken, uint256 _amount) public onlyOwner {
        uint256 allocTokenBal = allocToken.balanceOf(address(this));
        require(allocTokenBal >= _amount, "withdraw: not good");
        safeAllocTokenTransfer(allocToken, msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, address(allocToken), _amount);
    }

    // Safe allocToken transfer function, just in case if rounding error causes pool to not have enough tokens.
    function safeAllocTokenTransfer(IPEP20 allocToken, address _to, uint256 _amount) internal {
        uint256 allocTokenBal = allocToken.balanceOf(address(this));
        if (_amount > allocTokenBal) {
            allocToken.safeTransfer(_to, allocTokenBal);
        } else {
            allocToken.safeTransfer(_to, _amount);
        }
    }
}
