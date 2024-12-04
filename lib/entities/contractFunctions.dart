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
    print("nu s-a putut" + e.toString());
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
  print("rezultat" + rezultat);
  print(rezultat.toString() + " " + rezultat.runtimeType.toString());
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
  print("rezultat" + rezultat);
  httpClient.close();
  print(rezultat.toString() + " " + rezultat.runtimeType.toString());
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
  print("rezultat" + rezultat);
  httpClient.close();
  ethClient.dispose();
  print(rezultat.toString() + " " + rezultat.runtimeType.toString());
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
  print("rezultat" + rezultat);
  print(rezultat.toString() + " " + rezultat.runtimeType.toString());
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
  print("wrapper contract address " + Human().chain.wrapperContract.toString());
  print("web3 is of type " + Human().web3user.toString());
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
      print('tip cate ' + cate.runtimeType.toString());
      print("got the counter and it's " + cate.toString());
      var daoAddress = await getDAOAddress(cate - 1);
      daoAddress = daoAddress.toString();
      if (daoAddress.length > 20) {
        org.address = daoAddress;
        org.creationDate = DateTime.now();
        print("added project");
        print("suntem inainte de pop");
        print("projectAddress " + daoAddress.toString());
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
    print("nu s-a putut" + e.toString());
    // state.setState(() {
    //   state.widget.done=true;
    //   state.widget.error=true;
    // });
    return "still not ok";
  }
}

oldcreateDAO(Org org, state) async {
  Org parizer = Org(name: "new dao", description: "something description");
  parizer.decimals = 2;
  parizer.symbol = "SMO";
  parizer.executionDelay = 60;

  List<String> amounts = ["5000000", "3450000", "2", "3", "4000", "50"];
  List<String> initialMembers = [
    "0xa9F8F9C0bf3188cEDdb9684ae28655187552bAE9",
    "0xA6A40E0b6DB5a6f808703DBe91DbE50B7FC1fa3E"
  ];

  print("here we all are");

  print("wrapper contract address " + Human().chain.wrapperContract.toString());
  print("web3 is of type " + Human().web3user.toString());
  var sourceContract = Contract(
      Human().chain.wrapperContract, wrapperAbiStringGlobal, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed oki");
    final parameters = [
      parizer.name, // string
      parizer.symbol, // string
      parizer.description,
      parizer.decimals.toString(),
      parizer.executionDelay.toString(),
      initialMembers, // array of strings (addresses)
      amounts,
      ["something key"],
      ["something else value"],
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
      print('tip cate ' + cate.runtimeType.toString());
      print("got the counter and it's " + cate.toString());
      var daoAddress = await getDAOAddress(cate - 1);
      daoAddress = daoAddress.toString();
      if (daoAddress.length > 20) {
        parizer.address = daoAddress;
        parizer.creationDate = DateTime.now();
        print("added project");
        print("suntem inainte de pop");
        print("projectAddress " + daoAddress.toString());
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
    print("nu s-a putut" + e.toString());
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
  String concatenated = p.name.toString() +
      "0|||0" +
      p.type.toString() +
      "0|||0" +
      p.description.toString() +
      "0|||0" +
      p.externalResource.toString();
  print("web3user: " + Human().web3user.toString());
  var sourceContract = Contract(p.org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    final transaction =
        await promiseToFuture(callMethod(sourceContract, "propose", [
      [p.org.registryAddress],
      ["0"],
      [
        "0x2559ddf5000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000007636576616d6963000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000017736976616c6f617265616d65612076696e652061696369000000000000000000"
      ],
      concatenated
    ]));
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
    print("nu s-a putut" + e.toString());
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
  Uint8List descriptionBytes = Uint8List.fromList(utf8.encode(p.description!));

  // Convert bytes to a hexadecimal string
  Uint8List descriptionHashBytes = keccak256(descriptionBytes);
  String descriptionHash = "0x${bytesToHex(descriptionHashBytes)}";
  print("description hash: " + descriptionHash);
  var sourceContract = Contract(p.org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
  try {
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    final transaction =
        await promiseToFuture(callMethod(sourceContract, "queue", [
      ["0x60A93C29e3966c58a5227e1D76dcB185BAa1ac6b"],
      ["0"],
      [
        "0x2559ddf5000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000007636576616d6963000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000017736976616c6f617265616d65612076696e652061696369000000000000000000"
      ],
      ""
    ]));
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
    print("nu s-a putut" + e.toString());
    // state.setState(() {
    //   state.widget.done=true;
    //   state.widget.error=true;
    // });
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
      print("vote hash " + v.hash.toString());
      return v.hash;
    }
  } catch (e) {
    print("nu s-a putut" + e.toString());
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

execute(String address, String howMuch) async {
  print("executing on chain");
  await Future.delayed(Duration(seconds: 1));
  return 'done';
  var sourceContract =
      Contract(simpleDAOAddress, simpleDAOabiString, Human().web3user);
  print("facuram contractu");
  try {
    howMuch = howMuch + "000000000000000000";
    sourceContract = sourceContract.connect(Human().web3user!.getSigner());
    print("signed ok");
    final transaction = await promiseToFuture(
        callMethod(sourceContract, "execute", [address, howMuch]));
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
    print("nu s-a putut" + e.toString());
    return "still not ok";
  }
}

getNativeBalance(String address) async {
  var httpClient = Client();
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final ethAddress = EthereumAddress.fromHex(address);
  final balance = await ethClient.getBalance(ethAddress);
  print("balance:" + balance.getInWei.toString());
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
