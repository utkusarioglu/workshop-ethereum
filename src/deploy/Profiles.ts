import { strict as assert } from "assert";
import type { DeployFunction } from "hardhat-deploy/dist/types";

const deployment: DeployFunction = async ({
  deployments: { deploy },
  getNamedAccounts,
  storageLayout,
}) => {
  const contractName = "Profiles";
  const { deployer } = await getNamedAccounts();
  assert(!!deployer, "Deployer not available");
  const instance = (await deploy(contractName, {
    from: deployer,
  })) as any;
  await storageLayout.export();
  console.log(`${contractName} deployed at ${instance.address}`);
};

// export default deployment;
export default null;
