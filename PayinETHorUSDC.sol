// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract PayinETHorUSDC is ReentrancyGuard {
    address constant private WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant private GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
    address constant private USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address immutable private FactoryAddress;
    address immutable public Owner;
    IFactoryContract FactoryContract;
    ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IPeripheryPayments constant refundrouter = IPeripheryPayments(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    receive() external payable {}
    
    fallback() external payable {}

    constructor (address _FactoryAddress) {
        FactoryAddress = _FactoryAddress;
        FactoryContract = IFactoryContract(FactoryAddress);
        Owner = 0xeA4D1a08300247F6298FdAF2F68977Af7bf93d01;
    }
    
    modifier OnlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    modifier OnlyEscrows() {
        require(FactoryContract.EscrowsToOwners(msg.sender) != address(0), "This function can only be run by escrow accounts");
        _;
    }

    // Escrow only function for buying with ETH
    function ETHGMX(uint256 amountOut, uint24 poolFee, address _Buyer) external payable nonReentrant OnlyEscrows {
        if (poolFee == 5050) {
            uint256 amountOutHalf1 = amountOut / 2;
            uint256 amountOutHalf2 = amountOut - amountOutHalf1;
            uint256 amountInMaxHalf1 = msg.value / 2;
            uint256 amountInMaxHalf2 = msg.value - amountInMaxHalf1;
            ISwapRouter.ExactOutputSingleParams memory params1 = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: GMX,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf1,
                amountInMaximum: amountInMaxHalf1,
                sqrtPriceLimitX96: 0
            }); 
            ISwapRouter.ExactOutputSingleParams memory params2 = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: GMX,
                fee: 10000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf2,
                amountInMaximum: amountInMaxHalf2,
                sqrtPriceLimitX96: 0
            }); 
            router.exactOutputSingle{ value: amountInMaxHalf1 }(params1);
            router.exactOutputSingle{ value: amountInMaxHalf2 }(params2);
        } 
        else if (poolFee == 7525) {
            uint256 amountOutHalf2 = amountOut / 4;
            uint256 amountOutHalf1 = amountOut - amountOutHalf2;
            uint256 amountInMaxHalf2 = msg.value / 4;
            uint256 amountInMaxHalf1 = msg.value - amountInMaxHalf2;
            ISwapRouter.ExactOutputSingleParams memory params1 = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: GMX,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf1,
                amountInMaximum: amountInMaxHalf1,
                sqrtPriceLimitX96: 0
            }); 
            ISwapRouter.ExactOutputSingleParams memory params2 = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: GMX,
                fee: 10000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf2,
                amountInMaximum: amountInMaxHalf2,
                sqrtPriceLimitX96: 0
            }); 
            router.exactOutputSingle{ value: amountInMaxHalf1 }(params1);
            router.exactOutputSingle{ value: amountInMaxHalf2 }(params2);
        } 
        else if (poolFee == 2575) {
            uint256 amountOutHalf1 = amountOut / 4;
            uint256 amountOutHalf2 = amountOut - amountOutHalf1;
            uint256 amountInMaxHalf1 = msg.value / 4;
            uint256 amountInMaxHalf2 = msg.value - amountInMaxHalf1;
            ISwapRouter.ExactOutputSingleParams memory params1 = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: GMX,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf1,
                amountInMaximum: amountInMaxHalf1,
                sqrtPriceLimitX96: 0
            }); 
            ISwapRouter.ExactOutputSingleParams memory params2 = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: GMX,
                fee: 10000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf2,
                amountInMaximum: amountInMaxHalf2,
                sqrtPriceLimitX96: 0
            }); 
            router.exactOutputSingle{ value: amountInMaxHalf1 }(params1);
            router.exactOutputSingle{ value: amountInMaxHalf2 }(params2);
        }
        else {
            ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
                .ExactOutputSingleParams({
                    tokenIn: WETH,
                    tokenOut: GMX,
                    fee: poolFee,
                    recipient: msg.sender,
                    deadline: block.timestamp,
                    amountOut: amountOut,
                    amountInMaximum: msg.value,
                    sqrtPriceLimitX96: 0
                });

            router.exactOutputSingle{ value: msg.value }(params);
            }
        refundrouter.refundETH();
        (bool success,) = _Buyer.call{ value: address(this).balance }("");
        require(success, "refund failed");

    }

    // Escrow only function for buying with ETH
    function USDCGMX(uint256 amountOut, uint256 amountInMax, uint24 poolFee, address _Buyer) external payable nonReentrant OnlyEscrows {
        uint24 poolFee3000 = 3000;
        uint24 poolFee10000 = 10000;
        uint24 poolFee500 = 500;
        uint256 amountInHalf1;
        uint256 amountInHalf2;
        uint256 amountIn;
        TransferHelper.safeApprove(USDC, address(router), amountInMax);
        if (poolFee == 5050) {
            uint256 amountOutHalf1 = amountOut / 2;
            uint256 amountOutHalf2 = amountOut - amountOutHalf1;
            uint256 amountInMaxHalf1 = amountInMax/ 2;
            uint256 amountInMaxHalf2 = amountInMax - amountInMaxHalf1;
            ISwapRouter.ExactOutputParams memory params1 = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(GMX, poolFee3000, WETH, poolFee500, USDC),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf1,
                amountInMaximum: amountInMaxHalf1
            }); 
            ISwapRouter.ExactOutputParams memory params2 = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(GMX, poolFee10000, WETH, poolFee500, USDC),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf2,
                amountInMaximum: amountInMaxHalf2
            }); 
            amountInHalf1 = router.exactOutput(params1);
            amountInHalf2 = router.exactOutput(params2);
            amountIn = amountInHalf1 + amountInHalf2;
        } 
        else if (poolFee == 7525) {
            uint256 amountOutHalf2 = amountOut / 4;
            uint256 amountOutHalf1 = amountOut - amountOutHalf2;
            uint256 amountInMaxHalf2 = amountInMax / 4;
            uint256 amountInMaxHalf1 = amountInMax - amountInMaxHalf2;
            ISwapRouter.ExactOutputParams memory params1 = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(GMX, poolFee3000, WETH, poolFee500, USDC),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf1,
                amountInMaximum: amountInMaxHalf1
            }); 
            ISwapRouter.ExactOutputParams memory params2 = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(GMX, poolFee10000, WETH, poolFee500, USDC),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf2,
                amountInMaximum: amountInMaxHalf2
            }); 
            amountInHalf1 = router.exactOutput(params1);
            amountInHalf2 = router.exactOutput(params2);
            amountIn = amountInHalf1 + amountInHalf2;
        } 
        else if (poolFee == 2575) {
            uint256 amountOutHalf1 = amountOut / 4;
            uint256 amountOutHalf2 = amountOut - amountOutHalf1;
            uint256 amountInMaxHalf1 = amountInMax / 4;
            uint256 amountInMaxHalf2 = amountInMax - amountInMaxHalf1;
            ISwapRouter.ExactOutputParams memory params1 = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(GMX, poolFee3000, WETH, poolFee500, USDC),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf1,
                amountInMaximum: amountInMaxHalf1
            }); 
            ISwapRouter.ExactOutputParams memory params2 = ISwapRouter
            .ExactOutputParams({
                path: abi.encodePacked(GMX, poolFee10000, WETH, poolFee500, USDC),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOutHalf2,
                amountInMaximum: amountInMaxHalf2
            }); 
            amountInHalf1 = router.exactOutput(params1);
            amountInHalf2 = router.exactOutput(params2);
            amountIn = amountInHalf1 + amountInHalf2;
        }
        else {
            ISwapRouter.ExactOutputParams memory params = ISwapRouter
                .ExactOutputParams({
                    path: abi.encodePacked(GMX, poolFee, WETH, poolFee500, USDC),
                    recipient: msg.sender,
                    deadline: block.timestamp,
                    amountOut: amountOut,
                    amountInMaximum: amountInMax
                });
            amountIn = router.exactOutput(params);
        }
        if (amountIn < amountInMax) {
            TransferHelper.safeApprove(USDC, address(router), 0);
            TransferHelper.safeTransfer(USDC, _Buyer, amountInMax - amountIn);
        }
    }

    // Withdraw all ETH from this contract
    function WithdrawETH() external payable OnlyOwner nonReentrant {
        require(address(this).balance > 0);
        (bool sent, ) = Owner.call{value: address(this).balance}("");
        require(sent);
    }
    
    // Withdraw any ERC20 token from this contract
    function WithdrawToken(address _tokenaddress, uint256 _Amount) external OnlyOwner nonReentrant {
        TransferHelper.safeTransfer(_tokenaddress, Owner, _Amount);
    }
}

interface IFactoryContract {
    function EscrowsToOwners(address _Address) external view returns (address);
}
