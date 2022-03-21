// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

/*
@title MyVault
@license MIT
@author utkusarioglu
@notice A vault to automate and decentralize a long term donation strategy
*/
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

/// EACAggregatorProxy is used for chainlink oracle
interface EACAggregatorProxy {
  function latestAnswer() external view returns (uint256);
}

interface IUniswapRouter is ISwapRouter {
  function refundETH() external payable;
}

interface DepositableERC20 is IERC20 {
  function deposit() external payable;
}

contract MyVault {
  uint8 public version = 1;
  address public daiAddress;
  address public wethAddress;
  address public uniswapV3QuoterAddress;
  address public uniswapV3RouterAddress;
  address public chainLinkEthUsdAddress;

  uint256 public ethPrice = 0;
  uint256 public usdTargetPercentage = 40;
  uint256 public usdDividendPercentage = 25;
  uint256 public dividendFrequency = 3 minutes;
  uint256 public nextDividendTs;
  address public owner;

  using SafeERC20 for IERC20;
  using SafeERC20 for DepositableERC20;

  IERC20 daiToken;
  DepositableERC20 wethToken;
  IQuoter quoter;
  IUniswapRouter uniswapRouter;

  event MyVaultLog(string msg, uint256 ref);

  constructor(
    address _daiAddress,
    address _wethAddress,
    address _uniswapV3QuoterAddress,
    address _uniswapV3RouterAddress,
    address _chainLinkEthUsdAddress
  ) {
    daiAddress = _daiAddress;
    wethAddress = _wethAddress;
    uniswapV3QuoterAddress = _uniswapV3QuoterAddress;
    uniswapV3RouterAddress = _uniswapV3RouterAddress;
    chainLinkEthUsdAddress = _chainLinkEthUsdAddress;

    daiToken = IERC20(daiAddress);
    wethToken = DepositableERC20(wethAddress);
    quoter = IQuoter(uniswapV3QuoterAddress);
    uniswapRouter = IUniswapRouter(uniswapRouter);

    console.log("Deploying MyVault Version: ", version);
    nextDividendTs = block.timestamp + dividendFrequency;
    owner = msg.sender;
  }

  function getDaiBalance() public view returns (uint256) {
    return daiToken.balanceOf(address(this));
  }

  function getWethBalance() public view returns (uint256) {
    return wethToken.balanceOf(address(this));
  }

  function getTotalBalance() public view returns (uint256) {
    require(ethPrice > 0, "Eth price has not been set");
    uint256 daiBalance = getDaiBalance();
    uint256 wethBalance = getWethBalance();
    uint256 wethUsd = wethBalance * ethPrice;
    uint256 totalBalance = wethUsd + daiBalance;
    return totalBalance;
  }

  function updateEthPriceUniswap() public returns (uint256) {
    uint256 ethPriceRaw = quoter.quoteExactInputSingle(
      daiAddress,
      wethAddress,
      3000,
      1000000,
      0
    );
    ethPrice = ethPriceRaw / 100000;
    ethPrice = 1;
    console.log("eth price from uniswap: ", ethPrice);
    return ethPrice;
  }

  function updateEthPriceChainlink() public returns (uint256) {
    uint256 chainlinkEthPrice = EACAggregatorProxy(chainLinkEthUsdAddress)
      .latestAnswer();
    ethPrice = uint256(chainlinkEthPrice / 1e8);
    return ethPrice;
  }

  function buyWeth(uint256 amountUsd) internal {
    uint256 deadline = block.timestamp + 15;
    uint24 fee = 3000;
    address recipient = address(this);
    uint256 amountIn = amountUsd;
    uint256 amountOutMin = 0;
    uint160 sqrtPriceLimitsx96 = 0;
    emit MyVaultLog("amountIn", amountIn);
    require(
      daiToken.approve(address(uniswapV3QuoterAddress), amountIn),
      "DAI approve failed"
    );
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams(
        daiAddress,
        wethAddress,
        fee,
        recipient,
        deadline,
        amountIn,
        amountOutMin,
        sqrtPriceLimitsx96
      );
    uniswapRouter.exactInputSingle(params);
    uniswapRouter.refundETH();
  }

  function sellWeth(uint256 amountUsd) internal {
    uint256 deadline = block.timestamp + 15;
    uint24 fee = 3000;
    address recipient = address(this);
    uint256 amountOut = amountUsd;
    uint256 amountInMaximum = 10**28;
    uint160 sqrtPriceLimitX96 = 0;
    require(
      wethToken.approve(address(uniswapV3RouterAddress), amountOut),
      "WETH approve fail"
    );
    ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
      .ExactOutputSingleParams(
        wethAddress,
        daiAddress,
        fee,
        recipient,
        deadline,
        amountOut,
        amountInMaximum,
        sqrtPriceLimitX96
      );
    uniswapRouter.exactOutputSingle(params);
    uniswapRouter.refundETH();
  }

  function rebalance() public {
    require(msg.sender == owner, "Only the owner can do this");
    uint256 usdBalance = getDaiBalance();
    uint256 totalBalance = getTotalBalance();
    uint256 usdBalancePercentage = (100 * usdBalance) / totalBalance;
    emit MyVaultLog("usdBalancePercentage", usdBalancePercentage);
    if (usdBalancePercentage < usdTargetPercentage) {
      uint256 amountToSell = (totalBalance / 100) *
        (usdTargetPercentage - usdBalancePercentage);
      emit MyVaultLog("amountToSell", amountToSell);
      require(amountToSell > 0, "Nothing to sell");
      sellWeth(amountToSell);
    } else {
      uint256 amountToBuy = (totalBalance / 100) *
        (usdBalancePercentage - usdTargetPercentage);
      emit MyVaultLog("amountToBuy", amountToBuy);
      require(amountToBuy > 0, "NothingToBuy");
      buyWeth(amountToBuy);
    }
  }

  function annualDividend() public {
    require(msg.sender == owner, "Only the owner can do this");
    require(block.timestamp > nextDividendTs, "Dividend is not yet due");
    uint256 balance = getDaiBalance();
    uint256 amount = (balance * usdDividendPercentage) / 100;
    nextDividendTs = block.timestamp + dividendFrequency;
    daiToken.safeTransfer(owner, amount);
  }

  function closeAccount() public {
    require(msg.sender == owner, "Only the owner can call this");
    uint256 daiBalance = getDaiBalance();
    if (daiBalance > 0) {
      daiToken.safeTransfer(owner, daiBalance);
    }
    uint256 wethBalance = getWethBalance();
    if (wethBalance > 0) {
      wethToken.safeTransfer(owner, wethBalance);
    }
  }

  receive() external payable {}

  function wrapEth() public {
    require(msg.sender == owner, "Only the owner can call this");
    uint256 ethBalance = address(this).balance;
    require(ethBalance > 0, "No Eth available");
    emit MyVaultLog("wrapEth", ethBalance);
    wethToken.deposit{ value: ethBalance }();
  }
}
