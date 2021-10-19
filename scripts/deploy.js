async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Owner address:", deployer.address);
  
    const Lottery = await ethers.getContractFactory("Lottery");
    const LOTT = await Lottery.deploy();
  
    console.log("LOTTLINK Contract Address:", LOTT.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    