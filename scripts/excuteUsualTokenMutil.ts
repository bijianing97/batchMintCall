import { ethers } from "hardhat";

async function main() {
  const mainSigner = (await ethers.getSigners())[0];
  //   const batcher = await ethers.getContractFactory("Batcher");
  //   const batcherContract = await batcher.deploy(10);
  //   await batcherContract.deployed();
  //   console.log(
  //     "batcher contract deployed successfully to:",
  //     batcherContract.address
  //   );
  const batcher = await ethers.getContractAt(
    "Batcher",
    "0x87776535b9886C4bd0D09BA62f8c6DAeBE85D46c"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
