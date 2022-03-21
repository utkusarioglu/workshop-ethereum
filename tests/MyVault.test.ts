import { run, ethers } from "hardhat";
import { assert } from "chai";
import config from "config";
import type { MyVault } from "../artifacts/types/MyVault";

type DeployArgs = [string, string, string, string, string];

const contractName = "MyVault";
const addresses = [
  "dai",
  "weth",
  "uniswapV3Quoter",
  "uniswapV3Router",
  "chainlink",
].map((address) =>
  config.get<string>(`externalContracts.kovan.${address}`)
) as DeployArgs;

describe("MyVault", () => {
  let myVault: MyVault;

  beforeEach(async () => {
    await run("compile");
    const contract = await ethers.getContractFactory(contractName);
    myVault = await contract.deploy(...addresses);
    await myVault.deployed();
    console.log(`${contractName} deployed at ${myVault.address}`);
  });

  describe("Versioning", () => {
    it("Happy", async () => {
      const version = await myVault.version();
      assert.equal(version, 1);
    });
  });

  describe("Dai Balance", () => {
    it("zero", async () => {
      const daiBalance = await myVault.getDaiBalance();
      assert.equal(daiBalance.toString(), "0");
    });
  });

  describe("Rebalance Portfolio", () => {
    it("happy", async () => {
      const accounts = await ethers.getSigners();
      const owner = accounts[0];
      if (!owner) {
        throw new Error("Cannot find the owner account");
      }
      console.log(`Transferring ETH from owner address: ${owner.address}`);
      await owner.sendTransaction({
        to: myVault.address,
        value: ethers.utils.parseEther("0.01"),
      });
      await myVault.wrapEth();
      const ethPrice = await myVault.updateEthPriceUniswap();
      console.log("ethPrice\n", ethPrice);
      await myVault.rebalance();
      const daiBalance = await myVault.getDaiBalance();
      console.log(`Rebalanced Dai balance: ${daiBalance.toString()}`);
      assert.isAbove(daiBalance.toNumber(), 0);
    });
  });
});
