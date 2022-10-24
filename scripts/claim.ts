import { ethers } from "hardhat";

async function main() {
  const signers = await ethers.getSigners();
  console.log("signer:", signers[0].address);
  const muilContract2 = await ethers.getContractFactory("multiCall2");
  const muil2 = await muilContract2.deploy();
  await muil2.deployed();
  console.log("muil contract deployed successfully to:", muil2.address);
  const tx = await muil2.startClaim(10);
  await tx.wait();
  console.log("tx:", tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
