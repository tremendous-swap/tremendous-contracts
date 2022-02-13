pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./libs/IBEP20.sol";
import "./libs/SafeBEP20.sol";

// Token distributor.
contract TokenDistributor is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    event OwnerTokenRecovered(address tokenToRecover, uint256 amount);

    address[] tokenHolders = [
        0xa8736b9585a01d6dcc1b6e2fc9dc208552c34b58,
        0x634d25fa9eb6a142edd553535f3199b0d4ada0eb,
        0xb164ea44eb1c9b3c390c07c9f0fe6bac6b03de81,
        0x9aae2cc2315d65fdae9281c789a71c8b8418373c,
        0x40af3e31e4e7207a397d5fcf97228ed38783b08e,
        0xa512e549d68f15a9f23c1df98970e684301ac1e7,
        0x499ef7bf253ac266f990711ff900ac8bf8794dae,
        0x4c3ed1289c04087eb73f520a2d44049abefc807e
    ];

    constructor() public {}

    // Safe TMDS transfer function, just in case if rounding error causes pool to not have enough TMDSs.
    function sendTokens(
        uint256 from,
        uint256 to,
        uint256 amount,
        address tokenAddress
    ) external onlyOwner nonReentrant {
        require(from <= to, "Invalid indexes");
        uint256 addressCount = to.sub(from).add(1);
        uint256 tokenBalance = IBEP20(tokenAddress).balanceOf(address(this));
        require(
            amount.mul(addressCount) <= tokenBalance,
            "Insufficient token balance"
        );

        for (uint256 index = from; index <= to; index++) {
            IBEP20(tokenAddress).safeTransfer(tokenHolders[index], amount);
        }
    }

    /**
     * @notice It allows the operator to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by operator.
     */
    function recoverTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        IBEP20(_tokenAddress).transfer(msg.sender, _tokenAmount);
        emit OwnerTokenRecovered(_tokenAddress, _tokenAmount);
    }
}
