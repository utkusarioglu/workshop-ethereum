import { strict as assert } from "assert";
import type { DeployFunction } from "hardhat-deploy/dist/types";
import config from "config";

/**
 * #1 Typechain types are not used here to avoid type issues due to
 * #  outdated or yet absent types. The first run of hardhat ensures
 * #  the types are created or fixed.
 */
const deployment: DeployFunction = async ({
  deployments: { deploy },
  getNamedAccounts,
  storageLayout,
}) => {
  const contractName = "DGame";
  const { deployer } = await getNamedAccounts();
  assert(!!deployer, "Deployer not available");
  const instance = (await deploy(contractName, {
    from: deployer,
    args: [config.get("deployArgs.uri")],
  })) as any; // #1
  await storageLayout.export();
  console.log(`${contractName} deployed at ${instance.address}`);
};

export default deployment;
