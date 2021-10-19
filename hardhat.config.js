require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const { PRIVATE_KEY, ALCHEMY_API_KEY, POLYGONSCAN_API_KEY } = require('./secret.json');

module.exports = {
  solidity: "0.8.9",
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    polygon: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://polygonscan.com/ for polygon networks
    apiKey: `${POLYGONSCAN_API_KEY}`
  },
};
 