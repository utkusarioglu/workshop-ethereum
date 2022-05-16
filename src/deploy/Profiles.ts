import { strict as assert } from "assert";
import type { DeployFunction } from "hardhat-deploy/dist/types";

const deployment: DeployFunction = async ({
  deployments: { deploy },
  getNamedAccounts,
  storageLayout,
}) => {
  const enabled = false;
  const contractName = "Profiles";
  if (!enabled) {
    console.log(`Skipping contract "${contractName}" as it is set as disabled`);
    return;
  }
  const { deployer } = await getNamedAccounts();
  assert(!!deployer, "Deployer not available");
  const instance = (await deploy(contractName, {
    from: deployer,
  })) as any;
  await storageLayout.export();
  console.log(`"${contractName}" deployed at ${instance.address}`);
};

export default deployment;
