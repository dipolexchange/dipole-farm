pragma solidity 0.6.12;

import "./SmartChefInitializable.sol";

contract SmartChefFactory is Ownable {
    using SafeMath for uint256;
    using SafePEP20 for IPEP20;
    address public immutable WLAT;
    event NewSmartChefContract(address indexed smartChef, address stakedToken, address rewardToken, uint256 rewardPerBlock, uint256 startBlock, uint bonusEndBlock, uint poolLimitPerUser, address indexed admin);

    receive() external payable {
        IWLAT(WLAT).deposit{value: msg.value}();
    }

    constructor(address _WLAT) public {
        WLAT = _WLAT;
    }

    /*
     * @notice Deploy the pool
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _endBlock: end block
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     * @return address of new smart chef contract
     */
    function deployPool(
        IPEP20 _stakedToken,
        IPEP20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _poolLimitPerUser,
        address _admin
    ) external onlyOwner {
        require(_stakedToken.totalSupply() >= 0);
        require(_rewardToken.totalSupply() >= 0);
        require(_stakedToken != _rewardToken, "Tokens must be be different");

        bytes memory bytecode = type(SmartChefInitializable).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_stakedToken, _rewardToken, _startBlock));
        address payable smartChefAddress;

        assembly {
            smartChefAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        SmartChefInitializable(smartChefAddress).initialize(
            _stakedToken,
            _rewardToken,
            _rewardPerBlock,
            _startBlock,
            _bonusEndBlock,
            _poolLimitPerUser,
            _admin,
            WLAT
        );

        uint256 amountTransfer = _rewardPerBlock.mul(_bonusEndBlock - _startBlock);
        if(address(_rewardToken) == WLAT) {
            assert(IWLAT(WLAT).transfer(smartChefAddress, amountTransfer));
        } else {
            _rewardToken.safeTransfer(smartChefAddress, amountTransfer);
        }

        emit NewSmartChefContract(smartChefAddress, address(_stakedToken), address(_rewardToken), _rewardPerBlock, _startBlock, _bonusEndBlock, _poolLimitPerUser, _admin);
    }
}
