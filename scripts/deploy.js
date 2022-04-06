const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { METADATA_URL } = require("../constants");

async function main() {

  // const metadataURL = "http://localhost:3000/api/";
  //
  // const cloudsContract = await ethers.getContractFactory("CloudMint");
  //
  // const deployedCloudsContract = await cloudsContract.deploy(metadataURL);
  //
  // console.log("10 Clouds NFT Mint Contract Address:", deployedCloudsContract.address);

  // const CloudGovernance = await ethers.getContractFactory("CloudsGovernance");
  //
  // const cloudGovernance = await CloudGovernance.deploy();
  //
  // await cloudGovernance.deployed();
  //
  // console.log("Cloud Governance deployed to: ", cloudGovernance.address);

  const CloudProtocol = await ethers.getContractFactory("CloudsProtocol");

  const cloudProtocol = await CloudProtocol.deploy("0x17Db4501d4B319dF0507252cF152a6EF6727DF6B", "0x8d0a08EdC94c43Ce9D75D2c172D73DE30e053A82",
    {
      value: ethers.utils.parseEther("0.01"),
    }
  );

  await cloudProtocol.deployed();

  console.log("CloudProtocol deployed to: ", cloudProtocol.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
