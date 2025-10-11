// lib/src/services/dao_factory_abi.dart

import 'package:web3dart/web3dart.dart';

// This is the ABI string for flutter_web3
const String daoFactoryAbi = '''
[
  {
    "inputs": [
      {
        "components": [
          {
            "internalType": "string",
            "name": "name",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "symbol",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "description",
            "type": "string"
          },
          {
            "internalType": "uint256",
            "name": "decimals",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "executionDelay",
            "type": "uint256"
          },
          {
            "internalType": "address[]",
            "name": "initialMembers",
            "type": "address[]"
          },
          {
            "internalType": "uint256[]",
            "name": "amountsAndSettings",
            "type": "uint256[]"
          },
          {
            "internalType": "string[]",
            "name": "registryKeys",
            "type": "string[]"
          },
          {
            "internalType": "string[]",
            "name": "registryValues",
            "type": "string[]"
          },
          {
            "internalType": "bool",
            "name": "isTransferrable",
            "type": "bool"
          }
        ],
        "internalType": "struct DAOFactory.DAOParams",
        "name": "params",
        "type": "tuple"
      }
    ],
    "name": "deployDAOwithToken",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "daoAddress",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "tokenAddress",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "treasuryAddress",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "registryAddress",
        "type": "address"
      }
    ],
    "name": "NewDaoCreated",
    "type": "event"
  }
]
''';


// THE FIX: Add a class to hold the web3dart compatible ABI objects.
class Web3DartDaoFactory {
  static final abi = ContractAbi.fromJson(daoFactoryAbi, 'DAOFactory');
  
  static final deployDAOwithTokenFunction = abi.functions.firstWhere(
    (element) => element.name == 'deployDAOwithToken'
  );

  static final newDaoCreatedEvent = abi.events.firstWhere(
    (element) => element.name == 'NewDaoCreated'
  );
}