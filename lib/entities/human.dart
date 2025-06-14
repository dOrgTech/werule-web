import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'dart:js_util';
import '../main.dart';
import '../utils/functions.dart';

String prevChain = "0x1f47b";
String simpleDAOAddress = "0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF";
var chains = {
  "0xaa36a7": Chain(
      wrapperContract: "",
      wrapperContract_w: "",
      id: 11155111,
      name: "Sepolia",
      nativeSymbol: "sETH",
      decimals: 18,
      rpcNode: "https://sepolia.infura.io/v3/1081d644fc4144b587a4f762846ceede",
      blockExplorer: "https://sepolia.etherscan.io"),
  "0x1f47b": Chain(
      wrapperContract: "0x1e050e98F0215450bd41494F9B67bC3032c561D7",
      wrapperContract_w: "0xf4B3022b0fb4e8A73082ba9081722d6a276195c2",
      id: 128123,
      name: "Etherlink-Testnet",
      nativeSymbol: "XTZ",
      decimals: 18,
      rpcNode: "https://node.ghostnet.etherlink.com",
      blockExplorer: "https://testnet.explorer.etherlink.com"),
  "0xa729": Chain(
      wrapperContract: "",
      wrapperContract_w: "",
      id: 42793,
      name: "Etherlink",
      nativeSymbol: "XTZ",
      decimals: 18,
      rpcNode: "https://node.mainnet.etherlink.com",
      blockExplorer: "https://explorer.etherlink.com"),
};

class Human extends ChangeNotifier {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  String session_id = generateWalletAddress();
  bool busy = false;
  bool beta = true;
  bool wrongChain = false;
  int chainID = 5;
  bool landing = false;
  String chainNativeEarnings = "0";
  String chainUSDTEarnings = "0";
  String? address;
  Chain chain = chains[prevChain]!;
  bool metamask = true;
  bool allowed = false;
  Web3Provider? web3user;
  
  bool voting = false;
  bool isOverlayVisible = false;
  bool voted = false;
  List<ChatItem> chatHistory = [
    ChatItem(
      isSender: false,
      message:
          "If you have questions about the platform, ask them here. I'm not human but I'll do my best.",
    ),
  ];

  get balances => null;

  get actions => null;
  void refreshPage() {
    print("refreshing the page");
    _navigatorKey.currentState?.pushNamed("/");
  }

  Human._internal() {
    _setupListeners();
  }
  static final Human _instance = Human._internal();
  factory Human() {
    return _instance;
  }
  Future<void> _requestSwitchOrAddEtherlinkTestnet() async {
    const String targetChainId = "0x1f47b";
    final Chain targetChainDetails = chains[targetChainId]!;

    try {
      print("Attempting wallet_switchEthereumChain to $targetChainId");
      await promiseToFuture(ethereum!.request(RequestParams(
        method: 'wallet_switchEthereumChain',
        params: [{'chainId': targetChainId}],
      )));
      print("wallet_switchEthereumChain request sent. Waiting for chainChanged event.");
    } catch (switchError) {
      print("wallet_switchEthereumChain failed: $switchError. Attempting wallet_addEthereumChain.");
      try {
        var chainInfo = {
          "chainId": targetChainId,
          "chainName": targetChainDetails.name,
          "nativeCurrency": {
            "name": "Tezos", // Consistent with original
            "symbol": targetChainDetails.nativeSymbol,
            "decimals": targetChainDetails.decimals
          },
          "rpcUrls": [targetChainDetails.rpcNode],
          "blockExplorerUrls": [targetChainDetails.blockExplorer],
        };
        print("Attempting wallet_addEthereumChain for $targetChainId");
        await promiseToFuture(ethereum!.request(RequestParams(
          method: 'wallet_addEthereumChain',
          params: [chainInfo],
        )));
        print("wallet_addEthereumChain request sent. Waiting for chainChanged event.");
      } catch (addError) {
        print("wallet_addEthereumChain failed: $addError. User likely on wrong chain.");
        // If add also fails, user is stuck on wrong chain.
        // Set state to reflect this hard failure.
        chain = targetChainDetails; // Default to target for data loading
        wrongChain = true;
        web3user = null; // No valid web3user for the desired chain
        notifyListeners();
      }
    }
  }

  void _setupListeners() {
    if (ethereum != null) {
      ethereum!.on('accountsChanged', allowInterop((accounts) {
        if (accounts.isEmpty) {
          print("Wallet disconnected");
          address = null;
        } else {
          address = ethereum!.selectedAddress.toString();
          getUser(); // Assuming this is light and synchronous
          print("Account changed: $address");
        }
        notifyListeners();
      }));

      ethereum!.on('chainChanged', allowInterop((newChainIdHex) async {
        String newChainId = newChainIdHex.toString(); // Ensure it's a string
        print("Chain changed event. New chainId: $newChainId");
        const String etherlinkTestnetId = "0x1f47b";

        if (ethereum != null) {
          web3user = Web3Provider(ethereum!);
          try {
            final network = await promiseToFuture(web3user!.getNetwork());
            print('Provider network detected in chainChanged: ${getProperty(network, "name")}, chainId: ${getProperty(network, "chainId")}');
          } catch (e) {
            print('Error getting network from provider in chainChanged: $e');
          }
        } else {
          web3user = null;
        }

        if (newChainId == etherlinkTestnetId) {
          print("Chain is now Etherlink-Testnet.");
          wrongChain = false;
          chain = chains[etherlinkTestnetId]!;
          if (prevChain != etherlinkTestnetId) {
            await persist();
            refreshPage();
            prevChain = etherlinkTestnetId;
          }
        } else if (chains.keys.contains(newChainId)) {
          print("Chain is now another supported chain: $newChainId");
          wrongChain = false;
          chain = chains[newChainId]!;
          if (prevChain != newChainId) {
            await persist();
            refreshPage();
            prevChain = newChainId;
          }
        } else {
          print("Chain is now an unsupported chain: $newChainId. Requesting switch/add Etherlink-Testnet.");
          chain = chains[etherlinkTestnetId]!; // Default to Etherlink for data
          wrongChain = true; // Mark as wrong until switch/add succeeds
          notifyListeners(); // Notify UI about this intermediate state

          await _requestSwitchOrAddEtherlinkTestnet();
          // If switch/add is successful, this listener will be called again with the new chainId.
          // If it fails hard, _requestSwitchOrAddEtherlinkTestnet sets the final wrongChain state.
        }
        notifyListeners(); // Notify of final state from this handler
      }));
    }
  }

  getUser() {
    return User();
  }

  signIn() async {
    print("signing into the thing");
    const String etherlinkTestnetId = "0x1f47b";

    try {
      await promiseToFuture(
        ethereum!.request(RequestParams(method: 'eth_requestAccounts')),
      );
      address = ethereum?.selectedAddress.toString();
      var currentChainIdFromWallet = ethereum?.chainId.toString(); // Ensure string
      print("Current chainId from wallet after eth_requestAccounts: $currentChainIdFromWallet");

      if (ethereum != null) {
        web3user = Web3Provider(ethereum!);
        try {
          final network = await promiseToFuture(web3user!.getNetwork());
          print('Provider network detected after signIn: ${getProperty(network, "name")}, chainId: ${getProperty(network, "chainId")}');
        } catch (e) {
          print('Error getting network from provider after signIn: $e');
        }
      }

      if (currentChainIdFromWallet == etherlinkTestnetId) {
        print("Wallet connected on Etherlink-Testnet.");
        // Ensure state reflects this, especially if not already set by an early chainChanged event
        if (chain.id != chains[etherlinkTestnetId]!.id || wrongChain) {
          chain = chains[etherlinkTestnetId]!;
          wrongChain = false;
          if (prevChain != etherlinkTestnetId) {
            await persist();
            refreshPage();
            prevChain = etherlinkTestnetId;
          }
        }
      } else if (chains.keys.contains(currentChainIdFromWallet)) {
        print("Wallet connected on another supported chain: $currentChainIdFromWallet");
         if (chain.id != chains[currentChainIdFromWallet!]!.id || wrongChain) {
            chain = chains[currentChainIdFromWallet]!;
            wrongChain = false;
            if (prevChain != currentChainIdFromWallet) {
                await persist();
                refreshPage();
                prevChain = currentChainIdFromWallet;
            }
         }
      } else {
        print("Wallet connected on unsupported chain: $currentChainIdFromWallet. Requesting switch/add Etherlink-Testnet.");
        // Set an intermediate state before attempting switch
        chain = chains[etherlinkTestnetId]!; // Default to Etherlink for data
        wrongChain = true;
        notifyListeners();

        await _requestSwitchOrAddEtherlinkTestnet();
        // The chainChanged event will handle the final state update after switch/add attempt.
      }
      notifyListeners(); // Notify of any immediate changes from signIn
    } catch (e) {
      print("Error signing in: $e");
      chain = chains[etherlinkTestnetId]!; // Fallback
      wrongChain = true;
      web3user = null;
      notifyListeners();
    }
  }
}

class ChatItem {
  ChatItem({required this.isSender, required this.message});
  bool isSender;
  String message;
}

class User {}

class Action {
  Action({required this.type, required this.contract, required this.time});

  String type;
  String contract;
  DateTime time;
}

class Chain {
  Chain(
      {required this.id,
      required this.name,
      required this.nativeSymbol,
      required this.decimals,
      required this.rpcNode,
      required this.wrapperContract_w,
      required this.blockExplorer,
      required this.wrapperContract});
  int id;
  String name;
  String wrapperContract;
  String wrapperContract_w;
  int decimals;
  String nativeSymbol;
  String blockExplorer;
  String rpcNode;
  var fbCollection;
}
