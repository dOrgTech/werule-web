import 'package:Homebase/entities/abis.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // For connecting to Ethereum via JSON RPC
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:web3dart/crypto.dart';

Future<void> deployDaoSuite() async {
  print('Starting DAO Suite Deployment...');
  // Set up an HTTP client and the Web3 client
  final client = Web3Client('https://node.ghostnet.etherlink.com', Client());

  // Your private key and credentials
  String privateKey = '574b6dd16fe79a175be9dceaef2faf2ad30bc5b0f358ed20cffe93ee06947279';
  final credentials = EthPrivateKey.fromHex(privateKey);

  try {
    // Deploy Token contract
    print('Deploying Token contract with the following constructor arguments:');
    print('Token Name: MyToken, Symbol: MTK');
    print('Initial Members: [${credentials.address}]');
    print('Initial Amounts: [1000000000000000000000]');
    final tokenAddress = await deployContract(
      client: client,
      credentials: credentials,
      bytecode: tokenBytecodeGlobal,
      abi: tokenAbiGlobal,
      constructorArgs: [
        'MyToken', // Token name
        'MTK',    // Token symbol
        [credentials.address], // Initial members as a list
        [BigInt.parse('1000000000000000000000')] // Initial amounts as a list
      ],
      chainId: 128123,
      contractName: "Token"
    );
    print('Token deployed at: $tokenAddress');

    // Deploy TimeLockController contract
    print('Deploying TimeLockController contract with the following constructor arguments:');
    print('Min Delay: 0');
    print('Proposers: []');
    print('Executors: []');
    print('Admin: ${credentials.address}');
    final timelockAddress = await deployContract(
      client: client,
      credentials: credentials,
      bytecode: timelockBytecodeGlobal,
      abi: timelockAbiGlobal,
      constructorArgs: [
        BigInt.zero, // Minimum delay
        [], // Proposers list
        [], // Executors list
        credentials.address // Admin address
      ],
      chainId: 128123,
      contractName: "TimelockController"
    );
    print('Timelock deployed at: $timelockAddress');

    // Deploy HomebaseDAO contract
    print('Deploying HomebaseDAO contract with the following constructor arguments:');
    print('Token Address: $tokenAddress');
    print('Timelock Address: $timelockAddress');
    final daoAddress = await deployContract(
      client: client,
      credentials: credentials,
      bytecode: daoBytecodeGlobal,
      abi: daoAbiGlobal,
      constructorArgs: [
        tokenAddress,
        timelockAddress
      ],
      chainId: 128123,
      contractName: "HomebaseDAO"
    );
    print('DAO deployed at: $daoAddress');
  } finally {
    client.dispose();
  }
}

Future<EthereumAddress> deployContract({
  required Web3Client client,
  required EthPrivateKey credentials,
  required String bytecode,
  required List<dynamic> constructorArgs,
  required String abi,
  required int chainId,
  required String contractName,
}) async {
  if (bytecode.isEmpty || bytecode.length % 2 != 0) {
    throw FormatException("Invalid input length for $contractName bytecode, must be even.");
  }

  final contractAbi = ContractAbi.fromJson(abi, contractName);
  final constructorFunction = contractAbi.functions.firstWhere((f) => f.isConstructor, orElse: () => throw Exception('Constructor not found for $contractName'));
  final encodedConstructorParams = constructorFunction.encodeCall(constructorArgs);

  final deployData = Uint8List.fromList(hexToBytes(bytecode) + encodedConstructorParams);

  // Estimate gas for the deployment
  final estimatedGas = await client.estimateGas(
    sender: credentials.address,
    to: null,
    data: deployData,
    value: EtherAmount.zero(),
  );

  // Set a higher gas limit to ensure it is sufficient
  const maxGasLimit = 8000000;

  final deployTx = Transaction(
    to: null,
    data: deployData,
    value: EtherAmount.zero(),
    gasPrice: EtherAmount.inWei(BigInt.parse("60000000000")),
    maxGas: estimatedGas.toInt() * 2,
  );

  print("Deploying $contractName contract...");
  print('Estimated Gas for $contractName: ${estimatedGas.toInt()}');
  String txHash;
  try {
    txHash = await client.sendTransaction(
      credentials,
      deployTx,
      chainId: chainId,
    );
    print('$contractName transaction hash: $txHash');
  } catch (e) {
    print('Error during deployment of $contractName: \$e');
    rethrow;
  }

  // Wait for confirmation and get the contract address with retries
  final contractAddress = await waitForReceipt(client, txHash);
  if (contractAddress == null) {
    print('$contractName deployment failed. Please check the transaction on the explorer: $txHash');
    throw Exception('$contractName deployment failed due to execution reverted. Possible reasons: insufficient permissions, incorrect constructor parameters, or a requirement failed in the constructor.');
  }
  return contractAddress;
}

Future<EthereumAddress?> waitForReceipt(Web3Client client, String txHash) async {
  for (int i = 0; i < 30; i++) { // Retry up to 30 times
    final receipt = await client.getTransactionReceipt(txHash);
    if (receipt != null) {
      if (receipt.status == false) {
        print("Transaction failed: $txHash");
        return null;
      } else {
        print("Transaction succeeded: $txHash");
        return receipt.contractAddress;
      }
    }
    await Future.delayed(const Duration(seconds: 5));
    print('Retrying for transaction receipt: $txHash');
  }
  return null; // Return null if no receipt is found after retries
}
