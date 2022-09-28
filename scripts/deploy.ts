import { ethers } from "hardhat";

async function main() {
  const deployContract = await ethers.getContractFactory("Debby");

  const contract = await deployContract.deploy();

  await contract.deployed();

  console.log("Contract successfully deployed here:", contract.address);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
