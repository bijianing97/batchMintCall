import { ethers } from "hardhat";

async function main() {
  const signers = await ethers.getSigners();
  const signer0 = signers[0];
  const signer1 = signers[1];
  const nonce = await signer1.getTransactionCount();
  console.log("nonce", nonce);
  for (let i = 0; i < 10; i++) {
    signer1.sendTransaction({
      to: signer0.address,
      value: ethers.utils.parseEther("1"),
      nonce: nonce + i,
    });
    // await tx.wait();
    // console.log("tx:", tx.hash);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
