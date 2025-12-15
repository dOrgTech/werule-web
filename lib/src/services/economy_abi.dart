// lib/src/services/economy_abi.dart
import 'package:web3dart/web3dart.dart';

class EconomyAbi {
  static const _abiJson = '''
  [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "userAddress",
          "type": "address"
        }
      ],
      "name": "getUser",
      "outputs": [
        {
          "components": [
            {
              "internalType": "address[]",
              "name": "earnedTokens",
              "type": "address[]"
            },
            {
              "internalType": "uint256[]",
              "name": "earnedAmounts",
              "type": "uint256[]"
            },
            {
              "internalType": "address[]",
              "name": "spentTokens",
              "type": "address[]"
            },
            {
              "internalType": "uint256[]",
              "name": "spentAmounts",
              "type": "uint256[]"
            },
            {
              "internalType": "address[]",
              "name": "projectsAsAuthor",
              "type": "address[]"
            },
            {
              "internalType": "address[]",
              "name": "projectsAsContractor",
              "type": "address[]"
            },
            {
              "internalType": "address[]",
              "name": "projectsAsArbiter",
              "type": "address[]"
            }
          ],
          "internalType": "struct Economy.UserProfile",
          "name": "",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getConfig",
      "outputs": [
        {
          "components": [
            {
              "internalType": "address",
              "name": "timelockAddress",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "registryAddress",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "governorAddress",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "repTokenAddress",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "arbitrationFeeBps",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "platformFeeBps",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "authorFeeBps",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "coolingOffPeriod",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "backersVoteQuorumBps",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "projectThreshold",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "appealPeriod",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "maxImmediateBps",
              "type": "uint256"
            },
            {
              "internalType": "address",
              "name": "nativeProjectImplementation",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "erc20ProjectImplementation",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "numberOfProjects",
              "type": "uint256"
            }
          ],
          "internalType": "struct Economy.EconomyConfig",
          "name": "",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "name": "earnings",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "name": "spendings",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "repTokenAddress",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getNumberOfProjects",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "NATIVE_CURRENCY",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';

  static final abi = ContractAbi.fromJson(_abiJson, 'Economy');

  static String get abiJson => _abiJson;

  // Standard address used to represent native currency (ETH/XTZ) in the Economy contract
  static const nativeCurrencyAddress = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
}
