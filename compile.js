const path = require('path');
const fs = require('fs-extra');
const solc = require('solc');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const NFTPath = path.resolve(__dirname, 'contracts', 'NFT.sol');
const source = fs.readFileSync(NFTPath, 'utf8');

const input = {
  language: 'Solidity',
  sources: {
    'NFT.sol': {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
fs.ensureDirSync(buildPath);

fs.outputJsonSync(
    path.resolve(buildPath, 'NFT.json'),
    output.contracts['NFT.sol']['NFT']
);
