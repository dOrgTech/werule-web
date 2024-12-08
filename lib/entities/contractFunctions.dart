import 'dart:js_util';
import 'package:Homebase/entities/abis.dart';
import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/utils/functions.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // For connecting to Ethereum via JSON RPC
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:web3dart/crypto.dart';
import 'human.dart';
import 'org.dart';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:web3dart/crypto.dart';

delegate(String toWhom, Org org) async {
  var sourceContract =
      Contract(org.govTokenAddress!, tokenAbiString, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    final transaction =
        await promiseToFuture(callMethod(sourceContract, "delegate", [toWhom]));
    print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
      print("nu merge eroare de greseala");

      return "not ok";
    } else {
      var rezultat = (json.decode(stringify(result)));
      return rezultat.toString();
    }
  } catch (e) {
    print("nu s-a putut$e");
    return "not ok";
  }
}

getVotes(who, Org org) async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractWrapper = DeployedContract(
    ContractAbi.fromJson(tokenAbiGlobal, 'getVotes'),
    EthereumAddress.fromHex(org.govTokenAddress!),
  );
  var getRepToken = contractWrapper.function('getVotes');
  try {
    var counter = await ethClient.call(
      contract: contractWrapper,
      function: getRepToken,
      params: [EthereumAddress.fromHex(who)],
    );
    // Log the RPC response
    print('RPC Response for votes:');
    print(counter.toString());
    String rezultat = counter[0].toString();
    print('$rezultat ${rezultat.runtimeType}');
    httpClient.close();
    ethClient.dispose();
    return rezultat;
  } catch (e) {
    print('Error: $e');
    // Log the full response body
    print('Response Body:');
    print(httpClient.toString());
    rethrow;
  }
}

String getCalldata(ContractFunction functionAbi, List<dynamic> parameters) {
  final calldata = functionAbi.encodeCall(parameters);
  return "0x" + bytesToHex(calldata).toString();
}

getBalance(who, Org org) async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractWrapper = DeployedContract(
    ContractAbi.fromJson(tokenAbiGlobal, 'balanceOf'),
    EthereumAddress.fromHex(org.govTokenAddress!),
  );
  var getRepToken = contractWrapper.function('balanceOf');

  try {
    var counter = await ethClient.call(
      contract: contractWrapper,
      function: getRepToken,
      params: [EthereumAddress.fromHex(who)],
    );
    // Log the RPC response
    print('RPC Response balance:');
    print(counter.toString());
    String rezultat = counter[0].toString();
    print('$rezultat ${rezultat.runtimeType}');
    httpClient.close();
    return rezultat;
  } catch (e) {
    print('Error: $e');
    // Log the full response body
    print('Response Body:');
    print(httpClient.toString());
    httpClient.close();
    rethrow;
  }
}

getProposalVotes(Proposal p) async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final dao = DeployedContract(
    ContractAbi.fromJson(p.org.address!, 'state'),
    EthereumAddress.fromHex(p.org.address!),
  );
  var getRepToken = dao.function('state');
  Uint8List encodedData = getRepToken.encodeCall([]);
  try {
    var counter = await ethClient.call(
      contract: dao,
      function: getRepToken,
      params: [],
    );
    // Log the RPC response
    print('RPC Response STATE:');
    print(counter.toString());
    int againstVotes = int.parse(counter[0].toString()) as int;
    int forVotes = int.parse(counter[1].toString()) as int;
    int abstainVotes = int.parse(counter[2].toString()) as int;
    print('$againstVotes ${againstVotes}');
    httpClient.close();
    ethClient.dispose();
    return [againstVotes, forVotes, abstainVotes];
  } catch (e) {
    print('Error: $e');
    // Log the full response body
    print('Response Body:');
    print(httpClient.toString());
    rethrow;
  }
}

getProposalState(Proposal p) async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractWrapper = DeployedContract(
    ContractAbi.fromJson(daoAbiGlobal, 'state'),
    EthereumAddress.fromHex(p.org.address!),
  );
  var getRepToken = contractWrapper.function('state');

  try {
    var counter = await ethClient.call(
      contract: contractWrapper,
      function: getRepToken,
      params: [BigInt.parse(p.id!)],
    );
    // Log the RPC response
    print('RPC Response Proposal STATE');
    print(counter.toString());
    int rezultat = int.parse(counter[0].toString()) as int;
    print('$rezultat ${rezultat.runtimeType}');
    httpClient.close();
    ethClient.dispose();
    return rezultat;
  } catch (e) {
    print('Error: $e');
    // Log the full response body
    print('Response Body:');
    print(httpClient.toString());
    rethrow;
  }
}

getNumberOfDAOs() async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractWrapper = DeployedContract(
    ContractAbi.fromJson(wrapperAbiGlobal, 'getNumberOfDAOs'),
    EthereumAddress.fromHex(Human().chain.wrapperContract),
  );
  var getRepToken = contractWrapper.function('getNumberOfDAOs');
  Uint8List encodedData = getRepToken.encodeCall([]);
  try {
    var counter = await ethClient.call(
      contract: contractWrapper,
      function: getRepToken,
      params: [],
    );
    // Log the RPC response
    print('RPC Response for number of DAOs:');
    print(counter.toString());
    int rezultat = int.parse(counter[0].toString()) as int;
    print('$rezultat ${rezultat.runtimeType}');
    httpClient.close();
    ethClient.dispose();
    return rezultat;
  } catch (e) {
    print('Error: $e');
    // Log the full response body
    print('Response Body:');
    print(httpClient.toString());
    rethrow;
  }
}

getDAOAddress(position) async {
  print("getting dao address at position ${position}");
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa = DeployedContract(
      ContractAbi.fromJson(wrapperAbiGlobal, 'deployedDAOs'),
      EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedDAOs');
  print("intainte de marea functie");
  var counter = await ethClient.call(
      contract: contractSursa,
      function: getRepToken,
      params: [BigInt.from(position)]);
  String rezultat = counter[0].toString();
  print("rezultat$rezultat");
  print("$rezultat ${rezultat.runtimeType}");
  httpClient.close();
  return rezultat;
}

getTokenAddress(position) async {
  print("getting dao address at position ${position}");
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa = DeployedContract(
      ContractAbi.fromJson(wrapperAbiGlobal, 'deployedTokens'),
      EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedTokens');
  print("intainte de marea functie");
  var counter = await ethClient.call(
      contract: contractSursa,
      function: getRepToken,
      params: [BigInt.from(position)]);
  String rezultat = counter[0].toString();
  print("rezultat$rezultat");
  httpClient.close();
  print("$rezultat ${rezultat.runtimeType}");
  return rezultat;
}

getTreasuryAddress(position) async {
  print("getting dao address at position ${position}");
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa = DeployedContract(
      ContractAbi.fromJson(wrapperAbiGlobal, 'deployedTimelocks'),
      EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedTimelocks');
  print("intainte de marea functie");
  var counter = await ethClient.call(
      contract: contractSursa,
      function: getRepToken,
      params: [BigInt.from(position)]);
  String rezultat = counter[0].toString();
  print("rezultat$rezultat");
  httpClient.close();
  ethClient.dispose();
  print("$rezultat ${rezultat.runtimeType}");
  return rezultat;
}

getRegistryAddress(position) async {
  print("getting dao address at position ${position}");
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa = DeployedContract(
      ContractAbi.fromJson(wrapperAbiGlobal, 'deployedRegistries'),
      EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedRegistries');
  print("intainte de marea functie");
  var counter = await ethClient.call(
      contract: contractSursa,
      function: getRepToken,
      params: [BigInt.from(position)]);
  String rezultat = counter[0].toString();
  ethClient.dispose();
  httpClient.close();
  print("rezultat$rezultat");
  print("$rezultat ${rezultat.runtimeType}");
  return rezultat;
}

createDAO(Org org) async {
  List<String> amounts = [];
  List<String> initialMembers = [];
  for (String adresa in org.memberAddresses.keys) {
    initialMembers.add(adresa);
  }

  amounts = org.memberAddresses.values
      .map((member) =>
          BigInt.parse(member.personalBalance.toString()).toString())
      .toList();
  amounts.addAll([
    org.votingDelay.toString(),
    org.votingDuration.toString(),
    org.proposalThreshold.toString(),
    org.quorum.toString(),
  ]);
  print("wrapper contract address ${Human().chain.wrapperContract}");
  print("web3 is of type ${Human().web3user}");
  var sourceContract = Contract(
      Human().chain.wrapperContract, wrapperAbiStringGlobal, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed oki");

    final parameters = [
      org.name, // string
      org.symbol, // string
      org.description,
      org.decimals.toString(),
      org.executionDelay.toString(),
      initialMembers, // array of strings (addresses)
      amounts,
      org.registry.keys.toList(),
      org.registry.values.toList(),
    ];
    print("made params");
    for (var param in parameters) {
      print('Parameter: $param, Type: ${param.runtimeType}');
    }
    final jsDaoParams = jsify(parameters);
    final transaction = await promiseToFuture(
        callMethod(sourceContract, "deployDAOwithToken", [jsDaoParams]));
    print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];

    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
      print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat = (json.decode(stringify(result)));
      var cate = await getNumberOfDAOs();
      print('tip cate ${cate.runtimeType}');
      print("got the counter and it's $cate");
      var daoAddress = await getDAOAddress(cate - 1);
      daoAddress = daoAddress.toString();
      if (daoAddress.length > 20) {
        org.address = daoAddress;
        org.creationDate = DateTime.now();
        print("added project");
        print("suntem inainte de pop");
        print("projectAddress $daoAddress");
      }
      var tokenAddress = await getTokenAddress(cate - 1);
      tokenAddress = tokenAddress.toString();
      var treasuryAddress = await getTreasuryAddress(cate - 1);
      treasuryAddress = treasuryAddress.toString();
      var registryAddress = await getRegistryAddress(cate - 1);
      registryAddress = registryAddress.toString();
      List<String> results = [
        daoAddress,
        tokenAddress,
        treasuryAddress,
        registryAddress
      ];
      return results;
    }
  } catch (e) {
    print("nu s-a putut$e");
    // state.setState(() {
    //   state.widget.done=true;
    //   state.widget.error=true;
    // });
    return "still not ok";
  }
}

propose(Proposal p) async {
  print("description");
  print(p.description);
  String concatenated =
      "${p.name}0|||0${p.type}0|||0${p.description}0|||0${p.externalResource}";
  print("web3user: ${Human().web3user}");
  var sourceContract = Contract(p.org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
  String calldata0;
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    print("concatenated: $concatenated");
    print("targets ${p.targets}");
    print("values ${p.values}");
    print("calldatas ${p.callDatas}");
    final transaction = await promiseToFuture(callMethod(sourceContract,
        "propose", [p.targets, p.values, p.callDatas, concatenated]));
    print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
      print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat = (json.decode(stringify(result)));
      p.hash = rezultat.toString();
      var id = extractProposalId(rezultat);
      print("id: ${id.toString()}");
      BigInt idAsBigInt = BigInt.parse(id.toString());
      p.id = idAsBigInt.toString();
      return p.id;
    }
  } catch (e) {
    print("nu s-a putut$e");
    // state.setState(() {
    //                     state.widget.done=true;
    //                     state.widget.error=true;
    //                   });
    return "still not ok";
  }
}

// Helper function to convert Uint8List to hex string
String bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

queueProposal(Proposal p) async {
  String concatenatedDescription =
      "${p.name}0|||0${p.type}0|||0${p.description}0|||0${p.externalResource}";
  Uint8List encodedInput =
      Uint8List.fromList(utf8.encode(concatenatedDescription));
  Uint8List keccakHash = keccak256(encodedInput);
  String hashHex = "0x${bytesToHex(keccakHash)}";
  print("Keccak-256 hash: $hashHex");
  var sourceContract = Contract(p.org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    List<String> calldatas = [];
    for (String c in p.callDatas) {
      calldatas.add("0x" + c);
      print(c);
    }
    final transaction = await promiseToFuture(callMethod(
        sourceContract, "queue", [p.targets, p.values, calldatas, hashHex]));
    print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
      print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat = (json.decode(stringify(result)));
      print(rezultat);
      return rezultat.toString();
    }
  } catch (e) {
    print("nu s-a putut$e");
    state.setState(() {
      state.widget.done = true;
      state.widget.error = true;
    });
    return "still not ok";
  }
}

execute(Proposal p) async {
  String concatenatedDescription =
      "${p.name}0|||0${p.type}0|||0${p.description}0|||0${p.externalResource}";
  Uint8List encodedInput =
      Uint8List.fromList(utf8.encode(concatenatedDescription));
  Uint8List keccakHash = keccak256(encodedInput);
  String hashHex = "0x${bytesToHex(keccakHash)}";
  print("Keccak-256 hash: $hashHex");
  var sourceContract = Contract(p.org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    print("signed ok");
    List<String> calldatas = [];
    for (String c in p.callDatas) {
      calldatas.add("0x" + c);
      print(c);
    }
    final transaction = await promiseToFuture(callMethod(
        sourceContract, "execute", [p.targets, p.values, calldatas, hashHex]));
    print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
      print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat = (json.decode(stringify(result)));
      print(rezultat);
      return rezultat.toString();
    }
  } catch (e) {
    print("nu s-a putut$e");
    state.setState(() {
      state.widget.done = true;
      state.widget.error = true;
    });
    return "still not ok";
  }
}

vote(Vote v, Org org) async {
  var sourceContract = Contract(org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
  try {
    print("before signing");
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    final transaction = await promiseToFuture(callMethod(
        sourceContract, "castVote", [v.proposalID, v.option.toString()]));
    print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
      print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat = (json.decode(stringify(result.toString())));
      v.hash = extractTransactionHash(rezultat).toString();
      print("vote hash ${v.hash}");
      return v.hash;
    }
  } catch (e) {
    print("nu s-a putut$e");
    return "still not ok";
  }
}

String? extractTransactionHash(String transactionResponse) {
  try {
    // Parse the JSON-like string into a Map.
    final Map<String, dynamic> response = jsonDecode(transactionResponse);

    // Check if the transactionHash key exists and return it.
    return response['transactionHash'] ?? null;
  } catch (e) {
    // Return null if parsing or extraction fails.
    print("Error extracting transactionHash: $e");
    return null;
  }
}

getNativeBalance(String address) async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final ethAddress = EthereumAddress.fromHex(address);
  final balance = await ethClient.getBalance(ethAddress);
  print("balance:${balance.getInWei}");
  // Close the HTTP client
  httpClient.close();
  return balance.getInWei.toString();
  // return "1000000000";
}

/// Extracts the `proposalId` from a ProposalCreated event log
/// in a Governor contract transaction response.
BigInt? extractProposalId(Map<String, dynamic> transactionResponse) {
  print("starting to extract the id");
  const String proposalCreatedSignature =
      "0x7d84a6263ae0d98d3329bd7b46bb4e8d6f98cd35a7adb45c274c8b7fd5ebd5e0";

  // Step 2: Loop through the logs to find the ProposalCreated event.
  for (var log in transactionResponse['logs']) {
    print("executing here 1");
    // Check if the first topic matches the ProposalCreated signature.
    if (log['topics'][0] == proposalCreatedSignature) {
      // Step 3: Decode the `data` field to extract the `proposalId`.
      print("executing here 2");
      final String data = log['data'];
      print("executing here 3");

      // Decode the hex string into bytes.
      final Uint8List dataBytes = hexToBytes(data);
      print("executing here 4");
      // `proposalId` is the first 32 bytes of the `data`.
      final BigInt proposalId = bytesToBigInt(dataBytes.sublist(0, 32));

      // Validate that `proposalId` is a valid uint256.
      if (proposalId.sign >= 0) {
        return proposalId;
      }
    }
  }

  // If no ProposalCreated event was found, return null.
  return null;
}

/// Helper: Converts a hex string to bytes.
Uint8List hexToBytes(String hex) {
  final normalizedHex = hex.startsWith('0x') ? hex.substring(2) : hex;
  return Uint8List.fromList(List<int>.generate(normalizedHex.length ~/ 2,
      (i) => int.parse(normalizedHex.substring(i * 2, i * 2 + 2), radix: 16)));
}

/// Helper: Converts a byte array to BigInt.
BigInt bytesToBigInt(Uint8List bytes) {
  return BigInt.parse(
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(''),
      radix: 16);
}
