const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Owner address:", deployer.address);

    const Register = await ethers.getContractFactory("Register");
    const R = await Register.deploy("0x0000000000000000000000000000000000000000", "100000000000000000");
    console.log("Register Contract Address:", R.address);

    // const Consumer = await ethers.getContractFactory("RandomNumberConsumer");
    // const RNC = await Consumer.deploy();
    // console.log("Random Number Consumer Contract Address:", RNC.address);


    // const ChanceRoom = await ethers.getContractFactory("ChanceRoom");
    // const ChR = await ChanceRoom.deploy();
    // console.log("ChanceRoom Library Contract Address:", ChR.address);


    // const Factory = await ethers.getContractFactory("Factory");
    // const F = await Factory.deploy(R.address, RNC.address, ChR.address);
    // console.log("Factory Contract Address:", F.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    