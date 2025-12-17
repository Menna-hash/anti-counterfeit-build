import hre from "hardhat"; // Import the default HRE object

async function main() {
  // Access viem through 'hre.viem'
  const publicClient = await hre.viem.getPublicClient();

  const [deployer] = await hre.viem.getWalletClients();

  console.log("Deploying contracts with the account:", deployer.account.address);

  const product = await hre.viem.deployContract("ProductIdentification", []);

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
