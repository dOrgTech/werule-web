// lib/src/services/erc20_gov_abi.dart
import 'package:web3dart/web3dart.dart';

class Erc20GovAbi {
  // THE FIX: Add the 'delegate' and 'delegates' functions to the ABI.
  static const _abiJson = '''
  [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getVotes",
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
          "name": "delegatee",
          "type": "address"
        }
      ],
      "name": "delegate",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "delegates",
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

  static final abi = ContractAbi.fromJson(_abiJson, 'ERC20Votes');
  
  // THE FIX: Also expose the raw JSON for flutter_web3 which needs it for write transactions.
  static String get abiJson => _abiJson;
}
// lib/src/services/erc20_gov_abi.dart