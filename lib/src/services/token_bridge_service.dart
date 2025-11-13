// lib/src/services/token_bridge_service.dart

import 'dart:js_util';
import 'package:flutter/foundation.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';

/// Service for interacting with wrapped ERC20 token contracts
class TokenBridgeService {
  /// Get the balance of an ERC20 token for a given address
  Future<BigInt> getTokenBalance(String tokenAddress, String userAddress) async {
    if (ethereum == null || !ethereum!.isConnected()) {
      throw Exception("Wallet not connected");
    }

    final provider = Web3Provider(ethereum!);

    final abi = [
      'function balanceOf(address account) view returns (uint256)',
    ];

    final contract = Contract(tokenAddress, abi, provider);

    try {
      final balanceBN = await promiseToFuture(
          callMethod(contract, 'balanceOf', [userAddress]));
      final balanceString = callMethod(balanceBN, 'toString', []);
      return BigInt.parse(balanceString);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token balance: $e');
      }
      return BigInt.zero;
    }
  }

  /// Get the symbol of an ERC20 token
  Future<String> getTokenSymbol(String tokenAddress) async {
    if (ethereum == null || !ethereum!.isConnected()) {
      throw Exception("Wallet not connected");
    }

    final provider = Web3Provider(ethereum!);

    final abi = [
      'function symbol() view returns (string)',
    ];

    final contract = Contract(tokenAddress, abi, provider);

    try {
      final symbol = await promiseToFuture(callMethod(contract, 'symbol', []));
      return symbol as String;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token symbol: $e');
      }
      return 'TOKEN';
    }
  }

  /// Get the decimals of an ERC20 token
  Future<int> getTokenDecimals(String tokenAddress) async {
    if (ethereum == null || !ethereum!.isConnected()) {
      throw Exception("Wallet not connected");
    }

    final provider = Web3Provider(ethereum!);

    final abi = [
      'function decimals() view returns (uint8)',
    ];

    final contract = Contract(tokenAddress, abi, provider);

    try {
      final decimals = await promiseToFuture(callMethod(contract, 'decimals', []));
      return decimals as int;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token decimals: $e');
      }
      return 18;
    }
  }

  /// Wrap underlying tokens into governance tokens
  /// @param wrappedTokenAddress - The address of the wrapped token contract
  /// @param amount - Amount in wei (as string)
  Future<void> wrapTokens(String wrappedTokenAddress, String underlyingTokenAddress, String amount) async {
    if (ethereum == null || !ethereum!.isConnected()) {
      throw Exception("Wallet not connected");
    }

    final provider = Web3Provider(ethereum!);
    final signer = provider.getSigner();
    final userAddress = await promiseToFuture(callMethod(signer, 'getAddress', [])) as String;

    // First, approve the wrapped token contract to spend the underlying tokens
    final erc20Abi = [
      'function approve(address spender, uint256 amount) returns (bool)',
      'function allowance(address owner, address spender) view returns (uint256)',
    ];

    var underlyingContract = Contract(underlyingTokenAddress, erc20Abi, provider);
    underlyingContract = underlyingContract.connect(signer);

    // Check current allowance
    final allowanceBN = await promiseToFuture(
        callMethod(underlyingContract, 'allowance', [userAddress, wrappedTokenAddress]));
    final allowanceString = callMethod(allowanceBN, 'toString', []);
    final currentAllowance = BigInt.parse(allowanceString);
    final requiredAmount = BigInt.parse(amount);

    // If allowance is insufficient, approve
    if (currentAllowance < requiredAmount) {
      if (kDebugMode) {
        print('Approving wrapped token contract to spend underlying tokens...');
      }

      final approveTx = await promiseToFuture(
          callMethod(underlyingContract, 'approve', [wrappedTokenAddress, amount]));
      final approveHash = getProperty(approveTx, 'hash');
      await promiseToFuture(callMethod(provider, 'waitForTransaction', [approveHash]));

      if (kDebugMode) {
        print('Approval successful');
      }
    }

    // Now wrap the tokens
    final wrappedTokenAbi = [
      'function depositFor(address account, uint256 amount) returns (bool)',
    ];

    var wrappedContract = Contract(wrappedTokenAddress, wrappedTokenAbi, provider);
    wrappedContract = wrappedContract.connect(signer);

    if (kDebugMode) {
      print('Wrapping tokens...');
    }

    final wrapTx = await promiseToFuture(
        callMethod(wrappedContract, 'depositFor', [userAddress, amount]));
    final wrapHash = getProperty(wrapTx, 'hash');
    final result = await promiseToFuture(callMethod(provider, 'waitForTransaction', [wrapHash]));

    final status = getProperty(result, 'status');
    if (status != 1) {
      throw Exception("Transaction reverted on-chain");
    }

    if (kDebugMode) {
      print('Wrap successful');
    }
  }

  /// Unwrap governance tokens back to underlying tokens
  /// @param wrappedTokenAddress - The address of the wrapped token contract
  /// @param amount - Amount in wei (as string)
  Future<void> unwrapTokens(String wrappedTokenAddress, String amount) async {
    if (ethereum == null || !ethereum!.isConnected()) {
      throw Exception("Wallet not connected");
    }

    final provider = Web3Provider(ethereum!);
    final signer = provider.getSigner();
    final userAddress = await promiseToFuture(callMethod(signer, 'getAddress', [])) as String;

    final wrappedTokenAbi = [
      'function withdrawTo(address account, uint256 amount) returns (bool)',
    ];

    var wrappedContract = Contract(wrappedTokenAddress, wrappedTokenAbi, provider);
    wrappedContract = wrappedContract.connect(signer);

    if (kDebugMode) {
      print('Unwrapping tokens...');
    }

    final unwrapTx = await promiseToFuture(
        callMethod(wrappedContract, 'withdrawTo', [userAddress, amount]));
    final unwrapHash = getProperty(unwrapTx, 'hash');
    final result = await promiseToFuture(callMethod(provider, 'waitForTransaction', [unwrapHash]));

    final status = getProperty(result, 'status');
    if (status != 1) {
      throw Exception("Transaction reverted on-chain");
    }

    if (kDebugMode) {
      print('Unwrap successful');
    }
  }
}
