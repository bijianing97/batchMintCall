import { ethers } from "hardhat";

async function main() {
  const signers = await ethers.getSigners();
  const mainSigner = signers[0];
  console.log("signer:", mainSigner.address);
  //   const testContact = await ethers.getContractFactory("FallBackTest");
  //   const testContactDeployed = await testContact.deploy();
  //   await testContactDeployed.deployed();
  //   console.log("testContactDeployed:", testContactDeployed.address);
  const testContact = await ethers.getContractAt(
    "FallBackTest",
    "0xF47748e0b27E260ab1bc146a735D7bB62eAD05bE"
  );
  const tx = await mainSigner.sendTransaction({
    to: testContact.address,
    value: ethers.utils.parseEther("0.1"),
    data: "0x8a1104c70000000000000000000000000000000000000000000000000000000000000003",
    gasLimit: 1000000,
  });
  await tx.wait();
  const params = await testContact.params();
  console.log("params:", params);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
