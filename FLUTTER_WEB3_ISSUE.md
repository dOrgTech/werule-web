# Flutter Web3 Issue: Transaction Succeeds but Returns Empty Logs

## Problem Summary

When calling a Solidity function from a Flutter web app using `flutter_web3_provider`, the transaction appears to succeed (status: 1) but:
- Returns **0 logs** in the receipt
- The on-chain transaction trace shows **empty logs** and **empty output**
- Gas used is very low (~21k), suggesting the contract function exits early or reverts silently

## Environment

- **Flutter**: Web build
- **Package**: `flutter_web3_provider` (uses ethers.js v5 under the hood)
- **Network**: Etherlink Testnet (Chain ID: 128123)
- **Wallet**: MetaMask

## Contract Details

**TrustlessFactory Contract**: `0x74659e12F54a418B0d44C11bdAE9146e2CF526B1`

The function being called:
```solidity
function deployInfrastructure(uint48 timelockDelayInMinutes) external {
    // Deploys Economy, TimelockController, and Registry contracts
    // Emits: event InfrastructureDeployed(address economy, address registry, address timelock);
}
```

**Note**: The `onlyOwner` modifier was removed to rule out permission issues. Same behavior occurs.

## Flutter/Dart Code

```dart
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';

// Human-readable ABI
final List<String> humanReadableAbi = [
  'function deployInfrastructure(uint48 timelockDelayInMinutes)',
  'event InfrastructureDeployed(address economy, address registry, address timelock)',
];

// Create contract instance
final provider = Web3Provider(ethereum!);
var contract = Contract(factoryAddress, humanReadableAbi, provider);
contract = contract.connect(provider.getSigner());

// Call the function
final tx = await promiseToFuture(
    callMethod(contract, "deployInfrastructure", [1])); // timelockDelayInMinutes = 1

final hash = getProperty(tx, 'hash');
print("TX Hash: $hash"); // Prints valid hash

// Wait for receipt
final receipt = await promiseToFuture(callMethod(tx, 'wait', []));

final status = getProperty(receipt, 'status');
print("Status: $status"); // Prints: 1 (success)

final logs = getProperty(receipt, 'logs');
final logsLength = getProperty(logs, 'length') as int;
print("Logs count: $logsLength"); // Prints: 0 (PROBLEM!)
```

## On-Chain Transaction Trace

Transaction hash: `0x133b635d0fd1c3e86280776dd285bba5263c9bf63d09bb5839c9e82334c1b5ab`

From Etherlink Testnet explorer "Raw trace":
```json
{
    "calls": [],
    "from": "0x06e5b15bc39f921e1503073dbb8a5da2fc6220e9",
    "gas": "0x5edf",
    "gasUsed": "0x52d4",
    "input": "0xddd8778a0000000000000000000000000000000000000000000000000000000000000001",
    "logs": [],
    "output": "0x",
    "to": "0x74659e12f54a418b0d44c11bdae9146e2cf526b1",
    "type": "CALL",
    "value": "0x00"
}
```

**Key observations:**
- `gasUsed: 0x52d4` = ~21,204 gas - way too low for deploying 3 contracts
- `logs: []` - no events emitted
- `output: 0x` - empty output
- `calls: []` - no internal calls made

## What We've Tried

1. **Human-readable ABI format**:
   ```dart
   'function deployInfrastructure(uint48 timelockDelayInMinutes)'
   ```

2. **Full JSON ABI format** - but `flutter_web3_provider`'s `Contract` class requires `List<String>`, not JSON

3. **Different receipt fetching methods**:
   - `tx.wait()` - returns receipt with 0 logs
   - `provider.waitForTransaction(hash)` - returns receipt with 0 logs
   - `provider.getTransactionReceipt(hash)` - returns receipt with 0 logs

4. **Removed `onlyOwner` modifier** from contract and redeployed - same issue

5. **Verified wallet prompts correctly** - MetaMask shows the transaction, user confirms, transaction goes on-chain

6. **Verified function selector** - `0xddd8778a` correctly maps to `deployInfrastructure(uint48)`

## Working Reference: Same Contract via Hardhat

The exact same contract function works correctly when called via Hardhat/ethers.js in Node.js:

```javascript
const tx = await factory.deployInfrastructure(2);
const receipt = await tx.wait();
console.log(receipt.logs); // Contains InfrastructureDeployed event with addresses
```

## Suspected Issues

1. **Parameter encoding issue with `uint48`?** - The input data looks correct (`0x...0001` for value 1), but maybe ethers.js in Flutter is encoding differently?

2. **Gas estimation failing silently?** - The low gas used suggests the transaction might be running out of gas or hitting an early revert

3. **ABI mismatch?** - Perhaps the human-readable ABI format isn't being parsed correctly for `uint48` type?

4. **Provider/signer configuration issue?** - Something about how `flutter_web3_provider` wraps ethers.js?

## Questions

1. Has anyone successfully called a contract function with `uint48` parameter type from Flutter web using `flutter_web3_provider`?

2. Is there a way to get more detailed error information when a transaction "succeeds" but clearly didn't execute the expected code?

3. Should we try a different web3 package for Flutter? Alternatives?

## Files Involved

- `lib/src/services/create_dao_service.dart` - Contains `createEconomyDAO()` function
- `lib/src/features/dao_creator/providers/dao_creator_provider.dart` - Calls the service

## Additional Context

The same codebase has working contract calls for a simpler DAO factory that uses different function signatures. Those work fine. The difference is this contract uses:
- `uint48` parameter type (vs `uint256` in working code)
- Tuple/struct parameters in later steps (haven't gotten that far yet)
