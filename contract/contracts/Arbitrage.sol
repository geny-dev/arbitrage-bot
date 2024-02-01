// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IRouter {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IUniswapV2Router is IRouter {
    function swapExactTokensForETH(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts);
}

interface ISushiSwapRouter is IRouter {
    function swapExactETHForTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
}

contract Arbitrage {
    IRouter[] private routers;

    event Transfer(address indexed src, address indexed t0, address indexed t1, uint256 ai, uint256 ao, uint256 tp, uint256 wad);

    constructor() {
        routers = new IRouter[](2);
        routers[0] = IUniswapV2Router(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
        routers[1] = ISushiSwapRouter(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
    }

    function swap(address _token0, address _token1, uint256 _amountIn) public {

        address[] memory path0 = new address[](2);
        path0[0] = _token0;
        path0[1] = _token1;

        address[] memory path1 = new address[](2);
        path1[0] = _token1;
        path1[1] = _token0;
        
        uint256 amounts0 = routers[0].getAmountsOut(_amountIn, path0)[1];
        uint256 amounts1 = routers[1].getAmountsOut(_amountIn, path0)[1];
        amounts1 = routers[0].getAmountsOut(amounts1, path1)[1];
        amounts0 = routers[1].getAmountsOut(amounts0, path1)[1];

        require(amounts0 > _amountIn || amounts1 > _amountIn , "Arbitrage fail !");

        uint32 _type = 0;
        if (amounts0 < amounts1) {
            _type = 1;
        }

        IERC20(_token0).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_token0).approve(address(routers[_type]), _amountIn); 
        amounts0 = routers[_type].swapExactTokensForTokens(_amountIn, 0, path0, address(this), block.timestamp)[1];
        IERC20(_token1).approve(address(routers[1 - _type]), amounts0);
        amounts1 = routers[1 - _type].swapExactTokensForTokens(amounts0, 0, path1, msg.sender, block.timestamp)[1];
        require(amounts1 > _amountIn, "Arbitrage fail !");
        emit Transfer(msg.sender, _token0, _token1, _amountIn, amounts1, _type, block.timestamp);
    }
}