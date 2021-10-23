const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Owner address:", deployer.address);
  
    const Consumer = await ethers.getContractFactory("RandomNumberConsumer");
    const RNC = await Consumer.deploy();

    // const Lottery = await ethers.getContractFactory("Lottery");
    // const LOTT = await Lottery.deploy();
  
    console.log("Consumer contract Address:", RNC.address);
    // console.log("LOTTLINK Contract Address:", LOTT.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    