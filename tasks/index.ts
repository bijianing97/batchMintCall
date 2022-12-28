import { task, types } from "hardhat/config";

const xenAddress = "0x8abEC95592F26E6870dBF455dBea449344029546";
const batchAddress = "0x87776535b9886C4bd0D09BA62f8c6DAeBE85D46c";
const batchv2Address = "0x32033e6a75A72702c905bD23363c110a8719A66E";

const batcherABI = [
  "function execute(address,bytes)payable",
  "function withdraw(address)",
  "function withdrawETH(address)",
  "function destory()",
];

// 事实上这个是proxy的ABI，但是直接将callData传入，无法匹配到正确的函数，fallback会被调用，调用proxy.call(msg.data),从而实现了调用其他合约的目的

async function increaseTime(ethers: any, value: any) {
  if (!ethers.BigNumber.isBigNumber(value)) {
    value = ethers.BigNumber.from(value);
  }
  await ethers.provider.send("evm_increaseTime", [value.toNumber()]);
  await ethers.provider.send("evm_mine", []);
}

task("xen_claim_rank", "cliamRank for xen").setAction(async (taskArgs, hre) => {
  const mainSigner = (await hre.ethers.getSigners())[0];
  const batcher = new hre.ethers.Contract(batchAddress, batcherABI, mainSigner);
  //   hre.ethers.getContractAt("Prxoy", batchAddress);

  const xen = await hre.ethers.getContractAt(
    "XENCrypto",
    xenAddress,
    mainSigner
  );
  const tx = await batcher.execute(
    xenAddress,
    xen.interface.encodeFunctionData("claimRank", [1])
  );
  await tx.wait();
  console.log(
    "Xen balance",
    (await xen.balanceOf(mainSigner.address)).toString()
  );
});

task("xen_claim_reward", "cliam reward for xen").setAction(
  async (taskArgs, hre) => {
    const mainSigner = (await hre.ethers.getSigners())[0];
    const xen = await hre.ethers.getContractAt(
      "XENCrypto",
      xenAddress,
      mainSigner
    );
    const batcher = new hre.ethers.Contract(
      batchAddress,
      batcherABI,
      mainSigner
    );
    const tx = await batcher.execute(
      xen.address,
      xen.interface.encodeFunctionData("claimMintRewardAndShare", [
        mainSigner.address,
        100,
      ])
    );
    await tx.wait();
    console.log(
      "Xen balance",
      (await xen.balanceOf(mainSigner.address)).toString()
    );
  }
);

task("increase", "increase v2 counter")
  .addParam("count", "number to increase", undefined, types.int)
  .setAction(async (taskArgs, hre) => {
    const mainSigner = (await hre.ethers.getSigners())[0];
    const batcherv2 = await hre.ethers.getContractAt(
      "BatcherV2",
      batchv2Address
    );
    const tx = await batcherv2.increase(taskArgs.count);
    await tx.wait();
  });

task("xen_claim_rankv2", "cliamRank for xen").setAction(
  async (taskArgs, hre) => {
    const mainSigner = (await hre.ethers.getSigners())[0];
    const batcherv2 = await hre.ethers.getContractAt(
      "BatcherV2",
      batchv2Address
    );
    //   hre.ethers.getContractAt("Prxoy", batchAddress);

    const xen = await hre.ethers.getContractAt(
      "XENCrypto",
      xenAddress,
      mainSigner
    );
    const tx = await batcherv2.excuete(
      0,
      100,
      xenAddress,
      xen.interface.encodeFunctionData("claimRank", [1])
    );
    await tx.wait();
    console.log(
      "Xen balance",
      (await xen.balanceOf(mainSigner.address)).toString()
    );
  }
);
