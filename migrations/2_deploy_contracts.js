// const Multicall = artifacts.require("Multicall");
// const busd = artifacts.require("MockBEP20");
const SmartChefFactory = artifacts.require("SmartChefFactory");
const devAddr = '0x324b790ABbC496fFba372d7FBe6FA6eE68c5c675';
const wlat = '0xa71663bFa93Cd3DB7816fA65B156A0C652480a37';

module.exports = async function(deployer) {
    // await deployer.deploy(Multicall)
    // console.log('Multicall at: ', Multicall.address);
    // await deployer.deploy(busd, 'BUSD Token', 'BUSD', 200);

    // var currentBlockNumber = await web3.eth.getBlockNumber()
    await deployer.deploy(SmartChefFactory, wlat);
    console.log('SmartChefFactory at: ', SmartChefFactory.address);
};
