import { strict as assert } from "assert";
import type { DeployFunction } from "hardhat-deploy/dist/types";
import config from "config";

const kovanContracts = config.get<Record<string, string>>(
  "externalContracts.kovan"
);

const deployment: DeployFunction = async ({
  deployments: { deploy },
  getNamedAccounts,
  storageLayout,
}) => {
  const contractName = "MyVault";
  const { deployer } = await getNamedAccounts();
  assert(!!deployer, "Deployer not available");
  const deployed = await deploy(contractName, {
    from: deployer,
    args: Object.values(kovanContracts),
  });
  await storageLayout.export();
  console.log(`${contractName} deployed at ${deployed.address}`);
};

export default deployment;
