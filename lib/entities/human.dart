import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'dart:convert';
import 'dart:js';
import 'dart:js_util';
import '../entities/token.dart';
import 'dart:math';
import '../main.dart';
import '../utils/functions.dart';
import 'org.dart';
String prevChain="0x1f47b";
String simpleDAOAddress="0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF";
var chains={
 "0xaa36a7": Chain(
  wrapperContract:"",
   id:11155111, name: "Sepolia", nativeSymbol: "sETH", decimals:18, rpcNode: "https://sepolia.infura.io/v3/1081d644fc4144b587a4f762846ceede", blockExplorer:"https://sepolia.etherscan.io"),

 "0x1f47b": Chain(
  wrapperContract:"0x80df3CD253d388938F09e4fB836675Fa447d9351",
  id:128123, name: "Etherlink-Testnet", nativeSymbol: "XTZ", decimals:18, rpcNode: "https://node.ghostnet.etherlink.com", blockExplorer:"https://testnet-explorer.etherlink.com"),
 
 "0xa729": Chain(
  wrapperContract:"",
  id:42793, name: "Etherlink", nativeSymbol: "XTZ", decimals:18, rpcNode: "https://node.mainnet.etherlink.com", blockExplorer:"https://explorer.etherlink.com"),
};
class Human extends ChangeNotifier{
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
    GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
    String session_id=generateWalletAddress();
  bool busy=false;
  bool beta=true;
  bool wrongChain=false;
  int chainID=5;
  String chainNativeEarnings="0";
  String chainUSDTEarnings="0";
  String? address;
  Chain chain=chains[prevChain]!;
  bool metamask=true;
  bool allowed=false;
  Web3Provider? web3user;
  bool voting=false;
  bool isOverlayVisible = false;
  bool voted=false;
  List<ChatItem> chatHistory=[
    ChatItem(isSender: false, 
    message: "If you have questions about the platform, ask them here. I'm not human but I'll do my best.",
    ),
  ];

  get balances => null;

  get actions => null;
   void refreshPage() {
  print("refreshing the page");
    _navigatorKey.currentState?.pushNamed("/");
  }
  Human._internal(){
    _setupListeners();
  }
  static final Human _instance = Human._internal();
  factory Human() {
    return _instance;
  }
   void _setupListeners() {
    // Ensure Ethereum is available
    if (ethereum != null) {
      // Listen for account changes
      ethereum!.on('accountsChanged', allowInterop((accounts) {
        if (accounts.isEmpty) {
          // Handle wallet disconnection
          print("Wallet disconnected");
          address = null;
        } else {
          // Handle account change
          address = ethereum!.selectedAddress.toString();
          getUser();
          print("Account changed: $address");
        }
        notifyListeners(); // Notify listeners about the change
      }));

      // Listen for chain changes
      ethereum!.on('chainChanged', allowInterop((chainId) {
        print("Chain changed: $chainId");
        if (!chains.keys.contains(chainId)){
          print("schimbam la nimic");
          wrongChain=true;
          chain=Chain(wrapperContract:"", id: 0, name: 'N/A', nativeSymbol: '', decimals: 0, rpcNode: '', blockExplorer: "");
          notifyListeners();
          return "nogo";
        }else{
          web3user = Web3Provider(ethereum!);
          wrongChain=false;
          chain=chains[chainId]!;
           persist().then((value){
            print("users length ${users!.length}");
            // navigatorKey.currentState!.pushNamed("/");
            refreshPage();
            print("something");
           });
          }
        // Optionally update the chain information here
        notifyListeners(); // Notify listeners about the change
      }));
    }
  }

  getUser(){
    return User();
  }

  signIn()async{  
    print("signing into the thing") ;
    address="0x6EF597F8155BC561421800de48852c46e73d9D19";
    notifyListeners();
    refreshPage();
    return "ok";
   try {
      var accounts = await promiseToFuture(
        ethereum!.request(
          RequestParams(method: 'eth_requestAccounts'),
        ),
      );
      address = ethereum?.selectedAddress.toString();
      print("before waiting");
      await Future.delayed(Duration(milliseconds: 1500));
      print("before web3user is instantiated");
     
      print("before chainid");
      var chainaidi = ethereum?.chainId;
      print("chainid is "+chainaidi.toString());
       web3user = Web3Provider(ethereum!);
      print("web3user "+web3user.toString());
      if (!chains.keys.contains(chainaidi)){
          print("switching to nothing");
          wrongChain=true;
          chain=Chain(wrapperContract:"",
            id: 0, name: 'N/A', nativeSymbol: '', decimals: 0, rpcNode: '', blockExplorer: "");
          notifyListeners();
          return "nogo";
        }else{
          print("we are in this here else");
          wrongChain=false;
          chain=chains[chainaidi]!;
          if (! (chain==chains[prevChain])){
            // web3user = Web3Provider(ethereum!);
            await persist();
            refreshPage();}
          }
      
      print("after getting the web3user it is of type "+web3user.runtimeType.toString());
      // address="0xa9f8f9c0bf3188ceddb9684ae28655187552bae9";
      getUser();
      notifyListeners(); // Notify listeners that signIn was successful
      return "ok";
    } catch (e) {
      print(e);
      return "nogo";
    }
  }



}
class ChatItem{
  ChatItem({required this.isSender, required this.message});
  bool isSender;
  String message;
  
}
class User{

}

class Action {
  Action({required this.type, required this.contract, required this.time});

  String type;
  String contract;
  DateTime time;
}


class Chain{
  Chain({required this.id, required this.name,
   required this.nativeSymbol, required this.decimals, 
   required this.rpcNode, required this.blockExplorer,
   required this.wrapperContract
   });
  int id;
  String name;
  String wrapperContract;
  int decimals;
  String nativeSymbol;
  String blockExplorer;
  String rpcNode;
  var fbCollection;
}




