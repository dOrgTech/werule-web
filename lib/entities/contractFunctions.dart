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

delegate(String toWhom){
  return "delegated to $toWhom";

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
      return rezultat;
    } catch (e) {
      print('Error: $e');
      // Log the full response body
      print('Response Body:');
      print(httpClient.toString());
      rethrow;
    }
}

  getDAOAddress(position)async{
    print("getting dao address at position ${position}" );
  var httpClient = Client(); 
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa =
        DeployedContract(ContractAbi.fromJson(wrapperAbiGlobal,'deployedDAOs'), EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedDAOs');
  print("intainte de marea functie");
  var counter = await ethClient
          .call(contract: contractSursa, function: getRepToken, params: [BigInt.from(position)]);
    String rezultat= counter[0].toString();
    print("rezultat"+rezultat);
    print(rezultat.toString()+" "+rezultat.runtimeType.toString());
    return rezultat;
}
  getTokenAddress(position)async{
    print("getting dao address at position ${position}" );
  var httpClient = Client(); 
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa =
        DeployedContract(ContractAbi.fromJson(wrapperAbiGlobal,'deployedTokens'), EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedTokens');
  print("intainte de marea functie");
  var counter = await ethClient
          .call(contract: contractSursa, function: getRepToken, params: [BigInt.from(position)]);
    String rezultat= counter[0].toString();
    print("rezultat"+rezultat);
    print(rezultat.toString()+" "+rezultat.runtimeType.toString());
    return rezultat;
}
  getTreasuryAddress(position)async{
    print("getting dao address at position ${position}" );
  var httpClient = Client(); 
  var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
  final contractSursa =
        DeployedContract(ContractAbi.fromJson(wrapperAbiGlobal,'deployedTimelocks'), EthereumAddress.fromHex(Human().chain.wrapperContract));
  var getRepToken = contractSursa.function('deployedTimelocks');
  print("intainte de marea functie");
  var counter = await ethClient
          .call(contract: contractSursa, function: getRepToken, params: [BigInt.from(position)]);
    String rezultat= counter[0].toString();
    print("rezultat"+rezultat);
    print(rezultat.toString()+" "+rezultat.runtimeType.toString());
    return rezultat;
}

createDAO(Org org, state)async{
  return ["dao${generateWalletAddress()}", "token${generateWalletAddress()}", "treasury${generateWalletAddress()}"];
  print(" wrapper contract address "+Human().chain.wrapperContract.toString());
  print("web3 is of type "+Human().web3user.toString());
  var sourceContract = Contract(Human().chain.wrapperContract, wrapperAbiStringGlobal, Human().web3user);
  print("facuram contractu");
    try {
      sourceContract = sourceContract.connect(Human().web3user!.getSigner());
      print("signed ok");
      final transaction =
        await promiseToFuture(callMethod(sourceContract, "deployDAOwithToken", [
        org.name, // string
        org.govToken!.symbol, // string
        ["0xc5C77EC5A79340f0240D6eE8224099F664A08EEb",
        "0xA6A40E0b6DB5a6f808703DBe91DbE50B7FC1fa3E",
        "0x6EF597F8155BC561421800de48852c46e73d9D19"
        
        ], // array of strings (addresses)
        ["470000000000000000000",
        "18000000000000000000",
        "36000000000000000000"
        ], // array of strings representing uint256
        "1", // string representing uint48
        "2", // string representing uint32
      ]));
          print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
    print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat=(json.decode(stringify(result)));
      var cate= await getNumberOfDAOs();
      print('tip cate '+cate.runtimeType.toString());
      print("got the counter and it's " + cate.toString());
      var daoAddress=await getDAOAddress(cate - 1 );
      daoAddress=daoAddress.toString();
      if (daoAddress.length>20){
              org.address=daoAddress;
              org.creationDate=DateTime.now();
              print("added project");
              print("suntem inainte de pop");
      print ("projectAddress "+ daoAddress.toString());
          }
      var tokenAddress = await getTokenAddress(cate -1);
      tokenAddress = tokenAddress.toString();
      var treasuryAddress = await getTreasuryAddress(cate-1);
      treasuryAddress = treasuryAddress.toString();
      List<String> results = [daoAddress, tokenAddress, treasuryAddress];
      return results;
      }
    } catch (e) {    
        print("nu s-a putut" +e.toString());
        // state.setState(() {
          //   state.widget.done=true;
          //   state.widget.error=true;
          // });
      return "still not ok" ;
      }
  }

  propose(Proposal p)async{
     var sourceContract = Contract(p.org.address!, daoAbiString, Human().web3user);
  print("facuram contractu");
    try {
      sourceContract = sourceContract.connect(Human().web3user!.getSigner());
      print("signed ok");
      final transaction =
        await promiseToFuture(callMethod(sourceContract, "propose", [
        [p.transactions[0].recipient], 
        [p.transactions[0].value], 
        [p.transactions[0].callData], 
        p.description
      ]));
          print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
    print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat=(json.decode(stringify(result)));
      p.hash=rezultat.toString();
      return rezultat.toString();
      }
    } catch (e) {    
        print("nu s-a putut" +e.toString());
        // state.setState(() {
        //                     state.widget.done=true;
        //                     state.widget.error=true;
        //                   });
      return "still not ok" ;
      }
  }
   // Helper function to convert Uint8List to hex string
  String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  makeProposal()async{
    return "proposalHash${generateWalletAddress()}";
        var sourceContract = Contract(simpleDAOAddress, simpleDAOabiString, Human().web3user);
  print("facuram contractu");
    try {
      sourceContract = sourceContract.connect(Human().web3user!.getSigner());
      print("signed ok");
      final transaction =
        await promiseToFuture(callMethod(sourceContract, "createProposal", [
        "0xe06f1901be9db6ad06cb7388e622c47c75e9532ef0ec0022e022ddb25ba324d3"
      ]));
          print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
    print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat=(json.decode(stringify(result)));
      return rezultat.toString();
      }
    } catch (e) {    
        print("nu s-a putut" +e.toString());
        // state.setState(() {
      //   state.widget.done=true;
      //   state.widget.error=true;
      // });
      return "still not ok" ;
      }
  }

    queueProposal()async{
      return "ok";
        var sourceContract = Contract(simpleDAOAddress, simpleDAOabiString, Human().web3user);
  print("facuram contractu");
    try {
      sourceContract = sourceContract.connect(Human().web3user!.getSigner());
      print("signed ok");
      final transaction =
        await promiseToFuture(callMethod(sourceContract, "queueProposal", [
        "0xe06f1901be9db6ad06cb7388e622c47c75e9532ef0ec0022e022ddb25ba324d3"
      ]));
          print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
    print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat=(json.decode(stringify(result)));
      return rezultat.toString();
      }
    } catch (e) {    
        print("nu s-a putut" +e.toString());
      // state.setState(() {
      //   state.widget.done=true;
      //   state.widget.error=true;
      // });
      return "still not ok" ;
      }
  }

  vote()async{
    return "ok";
          var sourceContract = Contract(simpleDAOAddress, simpleDAOabiString, Human().web3user);
  print("facuram contractu");
    try {
      sourceContract = sourceContract.connect(Human().web3user!.getSigner());
      print("signed ok");
      final transaction =
        await promiseToFuture(callMethod(sourceContract, "vote", []));
        print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
    print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat=(json.decode(stringify(result)));
      return rezultat.toString();
      }
    } catch (e) {    
        print("nu s-a putut" +e.toString());
      
      return "still not ok" ;
      }
  }

  execute(String address, String howMuch)async{
    return 'done';
          var sourceContract = Contract(simpleDAOAddress, simpleDAOabiString, Human().web3user);
  print("facuram contractu");
    try {
      howMuch=howMuch+"000000000000000000";
      sourceContract = sourceContract.connect(Human().web3user!.getSigner());
      print("signed ok");
      final transaction =
        await promiseToFuture(callMethod(sourceContract, "execute", [
          address, howMuch
        ]));
        print("facuram tranzactia");
    final hash = json.decode(stringify(transaction))["hash"];
    final result = await promiseToFuture(
        callMethod(Human().web3user!, 'waitForTransaction', [hash]));
    if (json.decode(stringify(result))["status"] == 0) {
    print("nu merge eroare de greseala");
      return "not ok";
    } else {
      var rezultat=(json.decode(stringify(result)));
      return rezultat.toString();
      }
    } catch (e) {    
        print("nu s-a putut" +e.toString());
      return "still not ok" ;
      }
  }

  getNativeBalance(String address) async {
    var httpClient = Client(); 
    var ethClient = Web3Client(Human().chain.rpcNode, httpClient);
    final ethAddress = EthereumAddress.fromHex(simpleDAOAddress);
    final balance = await ethClient.getBalance(ethAddress);
    print("balance:"+ balance.getInWei.toString());
     // Close the HTTP client
    httpClient.close();
    return balance.getInWei.toString();
    // return "1000000000";
  }