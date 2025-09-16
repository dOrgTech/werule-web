// lib/src/services/erc20_gov_abi.dart
import 'package:web3dart/web3dart.dart';

class Erc20GovAbi {
  // THE FIX: Define the minimal JSON ABI for the getVotes function.
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
    }
  ]
  ''';

  // THE FIX: Create and expose a ContractAbi instance from the JSON.
  static final abi = ContractAbi.fromJson(_abiJson, 'ERC20Votes');
}
// lib/src/services/erc20_gov_abi.dart