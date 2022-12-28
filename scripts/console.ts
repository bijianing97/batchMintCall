import { artifacts, ethers } from "hardhat";
async function main() {
  const batch = await artifacts.readArtifact("BatchTransfer");
  const deployedBytecode = batch.deployedBytecode;
  const hash = ethers.utils.keccak256(deployedBytecode);
  console.log(hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
