import 'dart:js_util';

import 'package:Homebase/entities/abis.dart';
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
          [Human().address], // array of strings (addresses)
          ["500000000000000000"], // array of strings representing uint256
          "1", // string representing uint48
          "7", // string representing uint32
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
          //                     state.widget.done=true;
          //                     state.widget.error=true;
          //                   });
        return "still not ok" ;
        }
    }