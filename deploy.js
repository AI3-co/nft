const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
require('dotenv').config();

const { abi, evm } = require('./build/NFT.json');
const { exit } = require('process');

const provider = new HDWalletProvider(
  [process.env.PRIVATE_KEY],
  process.env.PROVIDER_URL,
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  const balance = await web3.eth.getBalance(accounts[0]);
  console.log('balance of account', web3.utils.fromWei(balance, 'ether'));
  console.log('Attempting to deploy from account', accounts[0]);

  let result;
  try {
    result = await new web3.eth.Contract(abi)
      .deploy({ data: evm.bytecode.object, arguments: [] })
      .send({ gas: '5000000', from: accounts[0], gasPrice: '20000000000' });
  } catch (error) {
    console.log(error);
    exit();
  }

  console.log('Contract deployed to', result.options.address);
  provider.engine.stop();
};
deploy();
