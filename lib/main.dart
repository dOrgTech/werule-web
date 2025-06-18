import 'dart:async';
import 'dart:typed_data';
import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/screens/bridge.dart';
import 'package:Homebase/screens/landing.dart';
import 'package:Homebase/screens/uni_bridge.dart';
import 'package:Homebase/utils/functions.dart';
import 'package:Homebase/utils/reusable.dart';
import 'package:Homebase/widgets/initiative.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'entities/org.dart';
import 'entities/token.dart';
import 'firebase_options.dart';
import 'screens/dao.dart';
import 'screens/explorer.dart';
import 'utils/theme.dart';
import 'entities/human.dart';
import 'package:Homebase/widgets/unsupported_chain_widget.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Already in human.dart
import 'package:provider/provider.dart';
import '../widgets/gameOfLife.dart'; // Assuming this path is correct

String metamask = "https://i.ibb.co/HpmDHg0/metamask.png";
List<Token> erc20Tokens = [];
List<Token> erc721Tokens = [];

// GlobalKey for GoRouter
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(
    ChangeNotifierProvider<Human>(
      create: (context) => Human(),
      child: const MyApp(),
    ),
  );
}

// Helper for transitions
Widget _fade(BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) =>
    FadeTransition(opacity: animation, child: child);
const _duration = Duration(milliseconds: 800);

// Function to create the router, can be called from MyApp
GoRouter _createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: Consumer<Human>(
              builder: (context, human, child) {
                if (human.landing == true) {
                  return Scaffold(body: Landing());
                }
                return FutureBuilder<void>(
                  future: human.dataReady,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(key: Key("root_loader_main")));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading data: ${snapshot.error}\n${snapshot.stackTrace}"));
                    }
                    if (human.wrongChain) {
                      return const UnsupportedChainWidget();
                    }
                    return Explorer();
                  },
                );
              },
            ),
            transitionsBuilder: _fade,
            transitionDuration: _duration,
          );
        },
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const Scaffold(body: Opacity(opacity: 0.1, child: GameOfLife())),
          transitionsBuilder: _fade,
          transitionDuration: _duration,
        ),
      ),
      GoRoute(
        path: '/nft',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: Scaffold(
            body: Center(
              child: Consumer<Human>(
                builder: (context, human, child) {
                  return FutureBuilder<void>(
                    future: human.dataReady,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(key: Key("nft_loader")));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error loading data: ${snapshot.error}"));
                      }
                      if (human.wrongChain) {
                        return const UnsupportedChainWidget();
                      }
                      if (human.orgs.isEmpty) {
                        return const Center(child: Text("No DAOs loaded for NFT page."));
                      }
                      return Initiative(org: human.orgs[0]);
                    },
                  );
                },
              ),
            ),
          ),
          transitionsBuilder: _fade,
          transitionDuration: _duration,
        ),
      ),
      GoRoute(
        path: '/bridge', // General bridge route, might need context if DAO specific
        pageBuilder: (context, state) {
          // This might need an Org parameter if it's DAO-specific
          // For now, assuming it's a general bridge UI
          return CustomTransitionPage(
            key: state.pageKey,
            child: const TokenWrapperUI(), 
            transitionsBuilder: _fade,
            transitionDuration: _duration,
          );
        },
      ),
      GoRoute(
        path: '/chain/:chainIdHex/:id', // :id is daoAddress
        pageBuilder: (context, state) {
          final String? chainIdHexFromUrl = state.pathParameters['chainIdHex'];
          final String? daoId = state.pathParameters['id'];
          if (chainIdHexFromUrl == null || daoId == null) {
            return CustomTransitionPage(child: Scaffold(body: Center(child: Text("Invalid URL: Missing chain or DAO ID."))), transitionsBuilder: _fade, transitionDuration: _duration);
          }
          return CustomTransitionPage(
            key: ValueKey("dao_${chainIdHexFromUrl}_$daoId"),
            child: DaoRouteWrapper(
              targetChainIdHex: chainIdHexFromUrl,
              daoId: daoId,
              isNested: false,
            ),
            transitionsBuilder: _fade,
            transitionDuration: _duration,
          );
        },
        routes: [
          GoRoute(
            path: ':nestedSegment',
            pageBuilder: (context, state) {
              final String? chainIdHexFromUrl = state.pathParameters['chainIdHex'];
              final String? daoAddress = state.pathParameters['id'];
              final String? nestedSegment = state.pathParameters['nestedSegment'];
              if (chainIdHexFromUrl == null || daoAddress == null || nestedSegment == null) {
                return CustomTransitionPage(child: Scaffold(body: Center(child: Text("Invalid URL for nested DAO segment."))), transitionsBuilder: _fade, transitionDuration: _duration);
              }
              return CustomTransitionPage(
                key: ValueKey("dao_nested_${chainIdHexFromUrl}_${daoAddress}_$nestedSegment"),
                child: DaoRouteWrapper(
                  targetChainIdHex: chainIdHexFromUrl,
                  daoId: daoAddress,
                  isNested: true,
                  nestedSegment: nestedSegment,
                ),
                transitionsBuilder: _fade,
                transitionDuration: _duration,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/:id', // Old route
        redirect: (BuildContext context, GoRouterState state) {
          final String? id = state.pathParameters['id'];
          final human = Provider.of<Human>(context, listen: false);
          final String currentChainHex = "0x${human.chain.id.toRadixString(16)}";
          print("Redirecting from old route /:id ($id) to /chain/$currentChainHex/$id");
          return '/chain/$currentChainHex/$id';
        },
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final human = Provider.of<Human>(context, listen: false);
    if (ethereum == null) {
      print("MyApp build: ethereum is null, setting human.metamask = false");
      human.metamask = false;
    } else {
      print("MyApp build: ethereum is not null, setting human.metamask = true");
      human.metamask = true;
    }

    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'weRule',
        theme: ThemeData(
            fontFamily: 'CascadiaCode',
            brightness: Brightness.dark,
            indicatorColor: const Color.fromARGB(255, 161, 215, 219),
            primaryColor: createMaterialColor(const Color(0xff4d4d4d)), // Ensure createMaterialColor is defined or use Colors.
            highlightColor: const Color(0xff6e6e6e),
            dividerColor: createMaterialColor(const Color(0xffcfc099)), // Ensure createMaterialColor is defined
            hintColor: Colors.white70,
            useMaterial3: false,
            // Add other theme properties from temanormal as needed
             colorScheme: ColorScheme.fromSwatch(
                brightness: Brightness.dark,
                primarySwatch: createMaterialColor(const Color.fromARGB(255, 255, 255, 255))
            ).copyWith(
                secondary: createMaterialColor(const Color(0xff383736))
            )
        ),
        routerConfig: _createRouter() // Call _createRouter here
      );
  }
}

class DaoRouteWrapper extends StatefulWidget {
  final String targetChainIdHex;
  final String daoId;
  final bool isNested;
  final String? nestedSegment;

  const DaoRouteWrapper({
    super.key,
    required this.targetChainIdHex,
    required this.daoId,
    required this.isNested,
    this.nestedSegment,
  });

  @override
  State<DaoRouteWrapper> createState() => _DaoRouteWrapperState();
}

class _DaoRouteWrapperState extends State<DaoRouteWrapper> {
  late Future<void> _chainSetupFuture;

  @override
  void initState() {
    super.initState();
    _chainSetupFuture = _initializeChain();
  }

  Future<void> _initializeChain() async {
    final human = Provider.of<Human>(context, listen: false);
    final String normalizedTargetChainIdHex = widget.targetChainIdHex.startsWith('0x') 
                                              ? widget.targetChainIdHex 
                                              : '0x${widget.targetChainIdHex}';
    final String currentHumanChainHex = "0x${human.chain.id.toRadixString(16)}";

    print("DaoRouteWrapper _initializeChain: Target: $normalizedTargetChainIdHex, Current: $currentHumanChainHex, DAO ID: ${widget.daoId}");

    if (currentHumanChainHex != normalizedTargetChainIdHex || human.orgs.isEmpty || human.wrongChain) {
       if (chains.containsKey(normalizedTargetChainIdHex)) { // Ensure target chain is known
           print("DaoRouteWrapper: Target chain $normalizedTargetChainIdHex differs or data needs load. Switching/Reloading.");
           // This will set human.chain, call persistAndComplete (which creates new dataReady future & notifies)
           await human.switchToChainAndReload(normalizedTargetChainIdHex); 
       } else {
           print("DaoRouteWrapper: Target chain $normalizedTargetChainIdHex from URL is unknown.");
           human.wrongChain = true; 
           if (!human.dataLoadCompleterIsCompleted) human.completeDataLoad();
           human.notifyListeners();
           // No throw needed, FutureBuilder will handle wrongChain
       }
    } else {
        print("DaoRouteWrapper: Already on target chain $normalizedTargetChainIdHex and data likely loaded.");
        if (!human.dataLoadCompleterIsCompleted) human.completeDataLoad();
        // No need to notify if nothing changed
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _chainSetupFuture, 
      builder: (context, setupSnapshot) {
        if (setupSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(key: Key("chain_setup_loader")));
        }
        // Do not check setupSnapshot.hasError here if _initializeChain handles its errors by setting human.wrongChain
        // or completing human.dataReady with an error.

        return Consumer<Human>(
          builder: (context, human, child) {
            // Now that _chainSetupFuture is complete, human.dataReady should be the one for the target chain (or completed with error)
            return FutureBuilder<void>(
              future: human.dataReady,
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(key: Key("dao_data_loader_wrapper")));
                }
                if (dataSnapshot.hasError) {
                  return Center(child: Text("Error loading DAO data: ${dataSnapshot.error}"));
                }
                if (human.wrongChain) { 
                  return const UnsupportedChainWidget();
                }
                
                final String currentHumanChainHex = "0x${human.chain.id.toRadixString(16)}";
                final String normalizedTargetChainIdHex = widget.targetChainIdHex.startsWith('0x') 
                                                          ? widget.targetChainIdHex 
                                                          : '0x${widget.targetChainIdHex}';

                if (currentHumanChainHex != normalizedTargetChainIdHex) {
                    return Center(child: Text("Chain switch in progress. Expected $normalizedTargetChainIdHex, currently on ${human.chain.name}."));
                }

                Org? orgToDisplay;
                bool hasOrg = human.orgs.any((o) => o.address == widget.daoId);
                if (hasOrg) {
                  orgToDisplay = human.orgs.firstWhere((o) => o.address == widget.daoId);
                }

                if (orgToDisplay == null) {
                  return Scaffold(body: Center(child: Text("DAO with ID '${widget.daoId}' not found on chain ${human.chain.name}.")));
                }

                if (widget.isNested) {
                  if (widget.nestedSegment!.toLowerCase() == 'bridge') {
                    return Bridge(org: orgToDisplay);
                  }
                  return DAO(org: orgToDisplay, InitialTabIndex: 1, proposalHash: widget.nestedSegment);
                } else {
                  return DAO(org: orgToDisplay, InitialTabIndex: 0);
                }
              },
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        // body: Explorer() // Example
        );
  }
}

class WalletBTN extends StatefulWidget {
  const WalletBTN({super.key});
  @override
  State<WalletBTN> createState() => _WalletBTNState();
}

class _WalletBTNState extends State<WalletBTN> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var human = Provider.of<Human>(context);

    if (human.busy) {
      return const SizedBox(
        width: 160,
        height: 7,
        child: Center(
          child: LinearProgressIndicator(
            minHeight: 2,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: () async {
        if (!human.metamask) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Container(
                  height: 260,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const Text(
                        "You need the a web3 wallet to sign into the app.",
                        style:
                            TextStyle(fontFamily: "Roboto Mono", fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            metamask, 
                            height: 100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Download it from",
                        style:
                            TextStyle(fontFamily: "Roboto Mono", fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse("https://metamask.io/"));
                          },
                          child: const Text(
                            "https://metamask.io/",
                            style: TextStyle(
                                fontFamily: "Roboto Mono", fontSize: 16),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          if (human.address == null) {
            await human.signIn();
          } else {
            print("WalletBTN: Already signed in, address: ${human.address}. Triggering data refresh.");
            // If already signed in, clicking might imply user wants to refresh or ensure correct chain
            await human.signIn(); // signIn logic now handles re-verification and potential data reload
          }
        }
      },
      child: SizedBox(
        width: 160,
        child: Center(
          child: human.address == null
              ? Row(
                  children: [
                    const SizedBox(width: 4),
                    Image.network(metamask, height: 27),
                    const SizedBox(width: 9),
                    const Text("Connect Wallet"),
                  ],
                )
              : Row(
                  children: [
                    FutureBuilder<Uint8List>(
                      future: generateAvatarAsync(hashString(human.address!)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(width: 40.0, height: 40.0, color: Colors.grey);
                        } else if (snapshot.hasData) {
                          return Image.memory(snapshot.data!, height: 40);
                        } else {
                          return Container(width: 40.0, height: 40.0, color: const Color.fromARGB(255, 116, 116, 116));
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(getShortAddress(human.address!)),
                  ],
                ),
        ),
      ),
    );
  }
}
