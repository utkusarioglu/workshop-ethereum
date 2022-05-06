import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import type { Profiles } from "_typechain/Profiles";
import { ethers } from "hardhat";
import {
  asSolidityStruct,
  localAccounts,
  beforeEachCommon,
} from "../src/services/test-helpers.service";
import { expect } from "chai";

const PROFILE_DEFAULT =
  "https://ipfs.io/ipfs/QmYV9HA1475SLrPuRbRtYWWiWrwHAisYmKALCUWgR4DRpU";

const CONTRACT_NAME = "Profiles";

describe(CONTRACT_NAME, () => {
  localAccounts.forEach(({ index, name, address }) => {
    let instance: Profiles;
    let signer: SignerWithAddress;
    type SetProfileInput = {
      config: Parameters<typeof instance.setProfile>[0];
      size: Parameters<typeof instance.setProfile>[1];
    };
    type SetProfileStruct = [
      SetProfileInput,
      Parameters<typeof instance.setProfile>
    ];

    describe(`As ${name} at ${address} (${index})`, () => {
      beforeEach(async () => {
        const common = await beforeEachCommon<Profiles>(
          CONTRACT_NAME,
          [],
          index
        );
        instance = common.signerInstance;
        signer = common.signer;
      });

      describe("function getProfile", () => {
        it("Returns default profile", async () => {
          const { struct } = asSolidityStruct({
            config: PROFILE_DEFAULT,
            size: ethers.BigNumber.from(64),
          });
          const result = await instance.getProfile({ from: signer.address });
          expect(result).to.deep.eq(struct);
        });

        it("Creates Profile", async () => {
          const { struct, tuple } = asSolidityStruct<SetProfileStruct>({
            config: "foo.png",
            size: ethers.BigNumber.from(20),
          });
          await instance.setProfile(...tuple);
          const result = await instance.getProfile();
          expect(result).to.deep.eq(struct);
        });

        it("Emits event while creating item", async () => {
          const { tuple } = asSolidityStruct<SetProfileStruct>({
            config: "foo.png",
            size: ethers.BigNumber.from(20),
          });
          await expect(instance.setProfile(...tuple))
            .to.emit(instance, "NewItem")
            .withArgs(signer.address, ...tuple);
        });

        it("Requires size > 0", async () => {
          const { tuple } = asSolidityStruct<SetProfileStruct>({
            config: "foo.png",
            size: ethers.BigNumber.from(0),
          });
          await expect(instance.setProfile(...tuple)).to.be.revertedWith(
            "SIZE_TOO_SMALL"
          );
        });
      });
    });
  });
});
