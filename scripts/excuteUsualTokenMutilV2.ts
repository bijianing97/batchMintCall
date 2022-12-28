import { ethers } from "hardhat";

async function main() {
  const mainSigner = (await ethers.getSigners())[0];
  //   const batcherv2 = await ethers.getContractFactory("BatcherV2");
  //   const batcherv2Contract = await batcherv2.deploy();
  //   await batcherv2Contract.deployed();
  //   console.log(
  //     "batcherv2 contract deployed successfully to:",
  //     batcherv2Contract.address
  //   );
  const batcherv2 = await ethers.getContractAt(
    "BatcherV2",
    "0x32033e6a75A72702c905bD23363c110a8719A66E"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
