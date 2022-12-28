import { ethers } from "hardhat";

async function main() {
  const account = "0xB7B19257d2499A7503E9240Fc43bFC82bC9B058B";
  const blockNumber = 7919054;
  const balance = await ethers.provider.getBalance(account, blockNumber);
  console.log(ethers.utils.formatEther(balance));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
