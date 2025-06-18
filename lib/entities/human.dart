import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'dart:js_util';
import '../utils/functions.dart';
import 'dart:async'; // For Completer
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore types
import 'org.dart'; // For Org type
import 'token.dart'; // For Token type
import 'proposal.dart'; // For Proposal type

String prevChain = "0x1f47b"; // Default to Etherlink-Testnet
String simpleDAOAddress = "0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF"; // Example, ensure it's used appropriately

var chains = {
  "0x1f47b": Chain(
      wrapperContract: "0x1e050e98F0215450bd41494F9B67bC3032c561D7", // Example address
      wrapperContract_w: "0xf4B3022b0fb4e8A73082ba9081722d6a276195c2", // Example address
      id: 128123,
      name: "Etherlink-Testnet",
      nativeSymbol: "XTZ",
      decimals: 18,
      rpcNode: "https://node.ghostnet.etherlink.com",
      blockExplorer: "https://testnet.explorer.etherlink.com"),
  "0xa729": Chain(
      wrapperContract: "0x3B342c54181A027929B67250855A35C7233DFD46", // Example address
      wrapperContract_w: "0xACFD7D5e73D3D0f0ae82a8156068297d65dCE70c", // Example address
      id: 42793,
      name: "Etherlink",
      nativeSymbol: "XTZ",
      decimals: 18,
      rpcNode: "https://node.mainnet.etherlink.com",
      blockExplorer: "https://explorer.etherlink.com"),
};

class Human extends ChangeNotifier {
  List<User> users = [];
  List<Org> orgs = [];
  List<Token> tokens = [];
  List<Proposal> proposals = [];
  var daosCollection;
  var tokensCollection;

  Completer<void> _dataLoadCompleter = Completer<void>()..complete();
  Future<void> get dataReady => _dataLoadCompleter.future;
  bool get dataLoadCompleterIsCompleted => _dataLoadCompleter.isCompleted;

  void completeDataLoad() {
    if (!_dataLoadCompleter.isCompleted) {
      _dataLoadCompleter.complete();
    }
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String session_id = generateWalletAddress();
  bool busy = false;
  bool beta = true;
  bool wrongChain = false;
  // int chainID = 5; // This seems unused, Human().chain.id is preferred
  bool landing = false; // Set to true if app should start on landing page
  String chainNativeEarnings = "0";
  String chainUSDTEarnings = "0";
  String? address;
  late Chain chain; // Will be initialized in _internal constructor
  bool metamask = true; // Assume true, update based on ethereum object
  bool allowed = false;
  Web3Provider? web3user;
  
  bool voting = false;
  bool isOverlayVisible = false;
  bool voted = false;
  List<ChatItem> chatHistory = [
    ChatItem(
      isSender: false,
      message: "If you have questions about the platform, ask them here. I'm not human but I'll do my best.",
    ),
  ];

  get balances => null;
  get actions => null;

  void refreshPage() {
    print("Human: refreshPage called. Navigating to /");
    _navigatorKey.currentState?.pushNamed("/"); // This might not be needed if UI reacts to notifyListeners
    notifyListeners();
  }

  Future<void> _persistInternal() async {
    print("Human._persistInternal: Loading data for chain: ${chain.name} (ID: ${chain.id.toRadixString(16)})");
    List<User> localUsers = [];
    List<Proposal> localProposals = [];
    List<Org> localOrgs = [];
    List<Token> localTokens = [];

    daosCollection = FirebaseFirestore.instance.collection("idaos${chain.name}");
    tokensCollection = FirebaseFirestore.instance.collection("tokens${chain.name}");

    try {
      var daosSnapshot = await daosCollection.get();
      var tokensSnapshot = await tokensCollection.get();

      for (var doc in tokensSnapshot.docs) {
        if (doc.data()['id'] == "native") continue;
        Token t = Token(
            type: doc.data()['type'],
            name: doc.data()['name'],
            symbol: doc.data()['symbol'],
            decimals: doc.data()['decimals']);
        t.address = doc.data()['address'];
        localTokens.add(t);
      }

      for (var doc in daosSnapshot.docs) {
        String orgName = doc.data()['name'] ?? "Unnamed Org";
        Org org = Org(
            name: orgName,
            description: doc.data()['description'],
            govTokenAddress: doc.data()['govTokenAddress']);
        org.address = doc.data()['address'];
        org.symbol = doc.data()['symbol'];
        if (doc.data()['creationDate'] is Timestamp) {
          org.creationDate = (doc.data()['creationDate'] as Timestamp).toDate();
        }
        org.govToken = Token(
            type: "erc20",
            symbol: org.symbol ?? "",
            decimals: doc.data()['decimals'], // Ensure org.decimals is set from doc if available
            name: org.name);
        org.govTokenAddress = doc.data()['token'];
        var wrappedValue = doc.data()['underlying'];
        if (wrappedValue is String && wrappedValue.isNotEmpty) {
          org.wrapped = wrappedValue;
        } else {
          org.wrapped = null;
        }
        print("Human._persistInternal DAO '${org.name}' (Address: ${org.address}): Processed 'underlying'. org.wrapped is now: ${org.wrapped}");
        org.proposalThreshold = doc.data()['proposalThreshold']?.toString();
        org.votingDelay = doc.data()['votingDelay'];
        org.registryAddress = doc.data()['registryAddress'];
        org.treasuryAddress = doc.data()['treasuryAddress'] ?? org.registryAddress; // Fallback for treasuryAddress
        org.votingDuration = doc.data()['votingDuration'];
        org.executionDelay = doc.data()['executionDelay'];
        org.quorum = doc.data()['quorum'];
        org.decimals = doc.data()['decimals'];
        org.holders = doc.data()['holders'];
        if (doc.data()['treasury'] is Map) {
            org.treasuryMap = Map<String, String>.from(doc.data()['treasury']);
        }
        if (doc.data()['registry'] is Map) {
            org.registry = Map<String, String>.from(doc.data()['registry']);
        }
        org.totalSupply = doc.data()['totalSupply']?.toString();
        org.debatesOnly = org.name.contains("dOrg");
        localOrgs.add(org);
      }

      users = localUsers;
      proposals = localProposals;
      orgs = localOrgs;
      tokens = localTokens;

      print("Human._persistInternal completed. Orgs loaded: ${orgs.length} for chain ${chain.name}");
    } catch (e, s) {
      print("Error in Human._persistInternal for chain ${chain.name}: $e\n$s");
      users = []; proposals = []; orgs = []; tokens = [];
      rethrow;
    }
  }

  Future<void> persistAndComplete() async {
    print("Human.persistAndComplete: Triggered for chain: ${chain.name}. Resetting dataLoadCompleter.");
    if (!_dataLoadCompleter.isCompleted) {
        print("Human.persistAndComplete: Previous load not completed. Completing it now before starting new one.");
        _dataLoadCompleter.complete(); // Complete previous if any, to avoid deadlock
    }
    _dataLoadCompleter = Completer<void>();

    try {
      await _persistInternal();
      if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
      print("Human.persistAndComplete: Data persistence complete for chain ${chain.name}.");
    } catch (e, s) {
      print("Human.persistAndComplete: Error during data persistence for chain ${chain.name}: $e\n$s");
      if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.completeError(e, s);
    }
    notifyListeners();
  }

  Human._internal() {
    chain = chains[prevChain] ?? chains.values.first;
    _setupListeners();
    if (!landing) {
       print("Human._internal: Initializing, not in landing mode. Calling persistAndComplete for ${chain.name}.");
       persistAndComplete();
    } else {
       print("Human._internal: Initializing, in landing mode. Marking dataLoadCompleter as complete.");
       if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
    }
  }
  static final Human _instance = Human._internal();
  factory Human() {
    return _instance;
  }

  Future<void> switchToChainAndReload(String targetChainIdHex) async {
    print("Human.switchToChainAndReload: Called for targetChainIdHex: $targetChainIdHex. Current chain: ${chain.name} (ID: 0x${chain.id.toRadixString(16)})");
    
    final String normalizedTargetChainIdHex = targetChainIdHex.startsWith('0x') ? targetChainIdHex : '0x$targetChainIdHex';

    if ("0x${chain.id.toRadixString(16)}" == normalizedTargetChainIdHex && orgs.isNotEmpty && !wrongChain) {
      print("Human.switchToChainAndReload: Already on target chain $normalizedTargetChainIdHex and data seems loaded. Not reloading.");
      if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
      notifyListeners();
      return;
    }

    Chain? targetChainDetails = chains[normalizedTargetChainIdHex];
    if (targetChainDetails != null) {
      print("Human.switchToChainAndReload: Target chain ${targetChainDetails.name} found. Current wallet chainId: ${ethereum?.chainId}");
      chain = targetChainDetails; // Optimistically set the chain
      wrongChain = false; 
      prevChain = normalizedTargetChainIdHex; 

      if (ethereum?.chainId?.toString() != normalizedTargetChainIdHex) {
        print("Human.switchToChainAndReload: Wallet is on a different chain (${ethereum?.chainId}). Requesting switch to ${targetChainDetails.name}.");
        await _requestSwitchOrAddNetwork(normalizedTargetChainIdHex, targetChainDetails);
        // The chainChanged listener will call persistAndComplete if switch is successful.
        // If switch fails, chainChanged might set wrongChain=true.
        // We call notifyListeners here to update UI if _requestSwitchOrAddNetwork itself sets wrongChain.
        notifyListeners(); 
      } else {
        print("Human.switchToChainAndReload: Wallet already on target chain ${targetChainDetails.name}. Fetching data.");
        await persistAndComplete(); // Already on the right chain, just fetch data.
      }
    } else {
      print("Human.switchToChainAndReload: Unknown targetChainIdHex: $normalizedTargetChainIdHex. Marking as wrongChain.");
      wrongChain = true;
      chain = chains[prevChain] ?? chains.values.first; // Revert to prev known good or default
      orgs = []; tokens = []; users = []; proposals = [];
      if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
      notifyListeners();
    }
  }

  Future<void> _requestSwitchOrAddNetwork(String targetChainIdHex, Chain targetChainDetails) async {
    if (ethereum == null) {
      print("Human._requestSwitchOrAddNetwork: Ethereum provider not available.");
      wrongChain = true;
      notifyListeners();
      return;
    }
    try {
      print("Human._requestSwitchOrAddNetwork: Attempting wallet_switchEthereumChain to $targetChainIdHex (${targetChainDetails.name})");
      await promiseToFuture(ethereum!.request(RequestParams(
        method: 'wallet_switchEthereumChain',
        params: [{'chainId': targetChainIdHex}],
      )));
      print("Human._requestSwitchOrAddNetwork: wallet_switchEthereumChain request for ${targetChainDetails.name} sent.");
    } catch (switchError) {
      print("Human._requestSwitchOrAddNetwork: wallet_switchEthereumChain to ${targetChainDetails.name} failed: $switchError. Attempting wallet_addEthereumChain.");
      try {
        var chainInfo = {
          "chainId": targetChainIdHex,
          "chainName": targetChainDetails.name,
          "nativeCurrency": { "name": targetChainDetails.nativeSymbol, "symbol": targetChainDetails.nativeSymbol, "decimals": targetChainDetails.decimals },
          "rpcUrls": [targetChainDetails.rpcNode],
          "blockExplorerUrls": [targetChainDetails.blockExplorer],
        };
        await promiseToFuture(ethereum!.request(RequestParams(
          method: 'wallet_addEthereumChain',
          params: [chainInfo],
        )));
        print("Human._requestSwitchOrAddNetwork: wallet_addEthereumChain request for ${targetChainDetails.name} sent.");
      } catch (addError) {
        print("Human._requestSwitchOrAddNetwork: wallet_addEthereumChain for ${targetChainDetails.name} failed: $addError.");
        wrongChain = true; // Explicitly set wrongChain if add fails
        notifyListeners();
      }
    }
  }

  Future<void> attemptSwitchToEtherlinkMainnet() async {
    const String etherlinkMainnetIdHex = "0xa729";
    final Chain? etherlinkMainnetDetails = chains[etherlinkMainnetIdHex];
    if (etherlinkMainnetDetails != null) {
      await _requestSwitchOrAddNetwork(etherlinkMainnetIdHex, etherlinkMainnetDetails);
    } else {
      print("Human.attemptSwitchToEtherlinkMainnet: Etherlink Mainnet details not found in chains map.");
    }
  }

  void _setupListeners() {
    if (ethereum != null) {
      ethereum!.on('accountsChanged', allowInterop((accounts) {
        print("Human.accountsChanged: Event received. Accounts: $accounts");
        if (accounts.isEmpty) {
          address = null;
        } else {
          address = ethereum!.selectedAddress.toString();
          getUser();
        }
        notifyListeners();
      }));

      ethereum!.on('chainChanged', allowInterop((newChainIdHexFromEvent) async {
        String newChainId = newChainIdHexFromEvent.toString();
        print("Human.chainChanged event: Wallet reported new chainId: $newChainId. Current Human().chain: ${chain.name} (0x${chain.id.toRadixString(16)}), prevChain global var: $prevChain");

        if (ethereum != null) web3user = Web3Provider(ethereum!); else web3user = null;

        Chain? newChainDetails = chains[newChainId];

        if (newChainDetails != null) {
          print("Human.chainChanged: New chain $newChainId (${newChainDetails.name}) is supported.");
          if ("0x${chain.id.toRadixString(16)}" != newChainId || prevChain != newChainId) {
            print("Human.chainChanged: Chain is different from current state or prevChain. Updating and reloading.");
            chain = newChainDetails;
            wrongChain = false;
            prevChain = newChainId; // Update global prevChain to reflect successful switch
            await persistAndComplete();
          } else {
            print("Human.chainChanged: New chain $newChainId is same as current and prevChain. No data re-fetch by chainChanged. Ensuring wrongChain is false.");
            if(wrongChain) wrongChain = false; // Correct wrongChain if it was true
            if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
            notifyListeners();
          }
        } else {
          print("Human.chainChanged: New chain $newChainId is UNSUPPORTED.");
          wrongChain = true;
          chain = chains["0xa729"] ?? chains.values.first; // Default to Etherlink Mainnet for UI
          orgs = []; tokens = []; users = []; proposals = [];
          if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
          notifyListeners();
        }
      }));
    } else {
        print("Human._setupListeners: ethereum object is null. Cannot set up listeners.");
        metamask = false; // Ensure metamask is false if ethereum is null at setup
    }
  }

  getUser() {
    return User();
  }

  signIn() async {
    print("Human.signIn: Attempting to sign in.");
    if (ethereum == null) {
      print("Human.signIn: Ethereum provider not available.");
      metamask = false;
      notifyListeners();
      return;
    }
    metamask = true;
    busy = true;
    notifyListeners();

    try {
      await promiseToFuture(ethereum!.request(RequestParams(method: 'eth_requestAccounts')));
      address = ethereum?.selectedAddress?.toString();
      String? currentChainIdFromWallet = ethereum?.chainId?.toString();
      print("Human.signIn: Wallet currentChainId: $currentChainIdFromWallet, address: $address");

      if (address == null || address!.isEmpty) {
        print("Human.signIn: No address obtained.");
        busy = false; notifyListeners(); return;
      }

      web3user = Web3Provider(ethereum!);
      Chain? detectedChainDetails = chains[currentChainIdFromWallet];

      if (detectedChainDetails != null) {
        print("Human.signIn: Wallet on supported chain: ${detectedChainDetails.name}. Current Human().chain: ${chain.name}");
        wrongChain = false;
        if ("0x${chain.id.toRadixString(16)}" != currentChainIdFromWallet || prevChain != currentChainIdFromWallet) {
          print("Human.signIn: Chain different from current state or prevChain. Updating and reloading.");
          chain = detectedChainDetails;
          prevChain = currentChainIdFromWallet!;
          await persistAndComplete();
        } else {
          print("Human.signIn: Chain same as current and prevChain. No re-fetch by signIn. Ensuring data completer is done.");
          if (!_dataLoadCompleter.isCompleted) await dataReady; // Wait if ongoing
          else if(orgs.isEmpty && !landing) await persistAndComplete(); // If completed but no orgs, try fetch
          else if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
        }
      } else {
        print("Human.signIn: Wallet on UNSUPPORTED chain: $currentChainIdFromWallet.");
        wrongChain = true;
        chain = chains["0xa729"] ?? chains.values.first;
        orgs = []; tokens = []; users = []; proposals = [];
        if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.complete();
        
        final Chain? etherlinkMainnetDetails = chains["0xa729"];
        if (etherlinkMainnetDetails != null) {
            await _requestSwitchOrAddNetwork("0xa729", etherlinkMainnetDetails);
        }
      }
    } catch (e,s) {
      print("Error during Human.signIn: $e\n$s");
      wrongChain = true;
      chain = chains["0xa729"] ?? chains.values.first;
      web3user = null; address = null;
      orgs = []; tokens = []; users = []; proposals = [];
      if (!_dataLoadCompleter.isCompleted) _dataLoadCompleter.completeError(e,s);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}

class ChatItem {
  ChatItem({required this.isSender, required this.message});
  bool isSender;
  String message;
}

class User {} // Basic User class, can be expanded

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
  var fbCollection; // This seems unused, consider removing or typing if used
}
