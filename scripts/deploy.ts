import { network } from "hardhat";

async function main() {
  // Connect to the network
  const connection = await network.connect();
  
  console.log("Connected to network:", connection.networkName);
  console.log("Connection object:", Object.keys(connection));

  // Access viem from the connection
  const viem = connection.viem;
  if (!viem) {
    throw new Error("Viem is not available. Make sure @nomicfoundation/hardhat-viem is properly configured.");
  }

  // Get wallet clients
  const [deployer] = await viem.getWalletClients();

  console.log("Deploying contracts with account:", deployer.account.address);

  // Deploy contract
  const product = await viem.deployContract("ProductIdentification", []);

  console.log("----------------------------------------------------");
  console.log("✅ Product System deployed successfully!");
  console.log("📍 Contract Address:", product.address);
  console.log("----------------------------------------------------");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });