import { run, ethers } from "hardhat";
import { expect } from "chai";
import type { ChainlinkConsumer } from "_contract-types/ChainlinkConsumer";
import config from "config";

type DeployArgs = [string];
const contractName = "ChainlinkConsumer";
const deployArgs: DeployArgs = [
  config.get("externalContracts.kovan.chainlink"),
];

describe("ChainlinkConsumer", () => {
  let instance: ChainlinkConsumer;

  beforeEach(async () => {
    await run("compile");
    const contract = await ethers.getContractFactory(contractName);
    instance = await contract.deploy(...deployArgs);
    await instance.deployed();
    console.log(`${contractName} deployed at ${instance.address}`);
  });

  describe("getLatestPrice()", () => {
    it("has `price > 0`", async () => {
      expect(await instance.getLatestPrice()).to.be.gt(
        ethers.BigNumber.from(0)
      );
    });
  });
});
