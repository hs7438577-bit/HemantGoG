const { ethers } = require("hardhat");

async function main() {
  const FlashStakeProtocol = await ethers.getContractFactory("FlashStakeProtocol");
  const flashStakeProtocol = await FlashStakeProtocol.deploy();

  await flashStakeProtocol.deployed();

  console.log("FlashStakeProtocol contract deployed to:", flashStakeProtocol.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
