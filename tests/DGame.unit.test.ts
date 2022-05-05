import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import type { DGame } from "_typechain/DGame";
import type { BigNumber } from "ethers";
import { ethers } from "hardhat";
import {
  localAccounts,
  beforeEachCommon,
} from "_services/test-helpers.service";
import { expect } from "chai";
import config from "config";

const CONTRACT_NAME = "DGame";

describe(CONTRACT_NAME, () => {
  localAccounts.slice(0, 1).forEach(({ index, name, address }) => {
    let instance: DGame;
    let signer: SignerWithAddress;
    let HEALTH: BigNumber;
    let BFG: BigNumber;
    let ROCKET: BigNumber;
    let MACHINE_GUN: BigNumber;
    let HAND_GUN: BigNumber;

    describe(`As ${name} at ${address} (${index})`, () => {
      beforeEach(async () => {
        const common = await beforeEachCommon<DGame>(
          CONTRACT_NAME,
          [config.get("deployArgs.uri")],
          index
        );
        instance = common.signerInstance;
        signer = common.signer;
        HEALTH = await instance.HEALTH();
        BFG = await instance.BFG();
        ROCKET = await instance.ROCKET();
        MACHINE_GUN = await instance.MACHINE_GUN();
        HAND_GUN = await instance.HAND_GUN();
      });

      describe("constructor", () => {
        it("Is ERC1155", async () => {
          const response = await instance.supportsInterface("0xd9b67a26");
          expect(response).to.be.true;
        });

        it("Creates HEALTH at expected amount", async () => {
          const response = await instance.balanceOf(signer.address, HEALTH);
          expect(response.toString()).to.eq((10 ** 2).toString());
        });

        it("Creates ROCKET at expected amount", async () => {
          const response = await instance.balanceOf(signer.address, BFG);
          expect(response.toString()).to.eq((1).toString());
        });

        it("Creates MACHINE_GUN at expected amount", async () => {
          const response = await instance.balanceOf(
            signer.address,
            MACHINE_GUN
          );
          const expected = ethers.BigNumber.from(2).pow(128).sub(1);
          expect(response).to.eq(expected);
        });

        it("Creates HAND_GUN at expected amount", async () => {
          const response = await instance.balanceOf(signer.address, HAND_GUN);
          const expected = ethers.BigNumber.from(2).pow(256).sub(1);
          expect(response).to.deep.eq(expected);
        });

        it("Sets expected Uri", async () => {
          const response = await instance.uri(HEALTH);
          expect(response).to.eq(config.get("deployArgs.uri"));
        });
      });

      describe("attack", () => {
        it("Emits 'Attack' event with expected args", async () => {
          const args: Parameters<typeof instance.attack> = [
            ethers.BigNumber.from(BFG),
            ethers.BigNumber.from(2),
          ];
          await expect(instance.attack(...args))
            .to.emit(instance, "Attack")
            .withArgs(signer.address, ...args);
        });
      });
    });
  });
});
