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
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../widgets/gameOfLife.dart';

String metamask = "https://i.ibb.co/HpmDHg0/metamask.png";
List<User>? users;
List<Org> orgs = [];
List<Token> tokens = [];
List<Proposal>? proposals;

var daosCollection;
var pollsCollection;
var votesCollection;
var tokensCollection;
// Us3r us3r = Us3r(human: humans[0]);
var systemCollection = FirebaseFirestore.instance.collection('some');

persist() async {
  print("persisting");

  users = [];
  proposals = [];
  daosCollection =
      FirebaseFirestore.instance.collection("idaos${Human().chain.name}");
  tokensCollection =
      FirebaseFirestore.instance.collection("tokens${Human().chain.name}");
  var daosSnapshot = await daosCollection.get();
  var tokensSnapshot = await tokensCollection.get();

  for (var doc in tokensSnapshot.docs) {
    print(doc.data());
    if (doc.data()['id'] == "native") {
      continue;
    }
    Token t = Token(
        type: doc.data()['type'],
        name: doc.data()['name'],
        symbol: doc.data()['symbol'],
        decimals: doc.data()['decimals']);
    t.address = doc.data()['address'];
    tokens.add(t);
  }
  orgs = [];

  for (var doc in daosSnapshot.docs) {
    print("we are doing this ");
    Org org = Org(
        name: doc.data()['name'],
        description: doc.data()['description'],
        govTokenAddress: doc.data()['govTokenAddress']);
    org.address = doc.data()['address'];
    org.symbol = doc.data()['symbol'];
    org.creationDate = (doc.data()['creationDate'] as Timestamp).toDate();
    org.govToken = Token(
        type: "erc20",
        symbol: org.symbol!,
        decimals: org.decimals,
        name: org.name);
    org.govTokenAddress = doc.data()['token'];
    var wrappedValue = doc.data()['wrapped'];
    if (wrappedValue is String) {
      org.wrapped = wrappedValue;
      print("FOUND A WRAPPED TOKEN string: ${org.wrapped}");
    } else {
      org.wrapped = null;
      if (wrappedValue != null) {
        print("Firestore field 'wrapped' was not null but was not a String. Type: ${wrappedValue.runtimeType}, Value: $wrappedValue");
      }
    }
    org.proposalThreshold = doc.data()['proposalThreshold'];
    org.votingDelay = doc.data()['votingDelay'];
    org.registryAddress = doc.data()['registryAddress'];
    org.treasuryAddress = org.registryAddress;
    org.votingDuration = doc.data()['votingDuration'];
    org.executionDelay = doc.data()['executionDelay'];
    org.quorum = doc.data()['quorum'];
    org.decimals = doc.data()['decimals'];
    org.holders = doc.data()['holders'];
    org.treasuryMap = Map<String, String>.from(doc.data()['treasury']);
    org.registry = Map<String, String>.from(doc.data()['registry']);
    org.totalSupply = doc.data()['totalSupply'];
    if (org.name.contains("dOrg")) {
      print("debates only ${org.name}");
      org.debatesOnly = true;
    } else {
      print("Full DAO  ${org.name}");
      org.debatesOnly = false;
    }
    orgs.add(org);
  }
}

List<Token> erc20Tokens = [];
List<Token> erc721Tokens = [];

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  if (Human().landing == false) {
    await persist();
    // List<dynamic>
  }

  runApp(ChangeNotifierProvider<Human>(
    create: (context) => Human(),
    child: const MyApp(),
  ));
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: Human().landing == true
              ? Scaffold(body: Landing())
              : FutureBuilder(
                  future: persist(),
                  builder: (context, snapshot) {
                    return Explorer();
                  },
                ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 800), // Increase fade time
        );
      },
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const Scaffold(body: Opacity(opacity: 0.1, child: GameOfLife())),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration:
            const Duration(milliseconds: 800), // Increase fade time
      ),
    ),
    GoRoute(
      path: '/nft',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Scaffold(
            body: Center(
                child: FutureBuilder(
                    future: persist(),
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? const CircularProgressIndicator()
                          : Initiative(
                              org: orgs[0],
                            );
                    }))),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration:
            const Duration(milliseconds: 800), // Increase fade time
      ),
    ),
    GoRoute( // New route for /bridge
      path: '/bridge',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const TokenWrapperUI(), // Assuming Bridge() widget is defined elsewhere
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 800),
        );
      },
    ),
    GoRoute(
      path: '/:id', // This 'id' is the <dao address>
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        Org? org;
        bool hasOrg = orgs.any((org) => org.address == id);
        if (hasOrg) {
          org = orgs.firstWhere((org) => org.address == id);
        } else {
          org = null;
        }
        var child = org == null
            ? FutureBuilder(
                future: persist(),
                builder: (context, snapshot) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (ModalRoute.of(context)?.isCurrent ?? false) {
                      context.go("/");
                    }
                  });
                  return Explorer();
                },
              )
            : DAO(org: org, InitialTabIndex: 0);

        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 800),
        );
      },
      routes: [
        GoRoute(
          path: ':nestedId', // This 'nestedId' can be 'bridge' or a proposal ID
          pageBuilder: (context, state) {
            final daoAddress = state.pathParameters['id']!;
            final nestedSegment = state.pathParameters['nestedId']!;

            Org org = orgs.firstWhere((org) => org.address == daoAddress,
                orElse: () {
                  throw Exception("DAO not found for address: $daoAddress while accessing $nestedSegment");
                });

            Widget pageContent;

            if (nestedSegment.toLowerCase() == 'bridge') {
              pageContent = Bridge(org: org);
            } else {
              pageContent = StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return DAO(
                    org: org,
                    InitialTabIndex: 1,
                    proposalHash: nestedSegment,
                  );
                },
              );
            }

            return CustomTransitionPage(
              key: state.pageKey,
              child: pageContent,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration:
                  const Duration(milliseconds: 800),
            );
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (ethereum == null) {
      print("n-are metamask");
      Human().metamask = false;
    } else {
      print("are metamask");
      Human().metamask = true;
    }

    // Proposal p;
    // if (true) {
    //   p = Proposal(org: orgs[0]);
    //   p.author =
    //       Human().address ?? "0xc5C77EC5A79340f0240D6eE8224099F664A08EEb";
    //   p.name = "sarmalele reci";
    //   p.description = "ce sa facem ca sa fie facut";
    //   p.createdAt = DateTime.now();
    //   p.targets = ["0xdestinationcontractad4099F664A08EEb"];
    //   p.values = ["0"];
    //   p.hash = makeProposal();
    //   p.externalResource = "asdasdasd";
    //   p.status = "active";
    //   p.type = "treasury";
    //   // p.type = "mint " + orgs[0].symbol.toString();
    //   // p.type = "mint " + orgs[0].symbol.toString();
    //   // p.callDatas = [
    //   //   {
    //   //     "recipient1address": "100000",
    //   //   }
    //   // ];
    //   p.callDatas = [
    //     {"treasuryAddress": "0x09a8ud02398du203987dyas8ouroyaiudy37"}
    //   ];
    //   p.store();
    // } else {
    //   p = orgs[0].proposals[0];
    // }

    ThemeData temanormal = ThemeData(
      fontFamily: 'CascadiaCode',
      splashColor: const Color(0xff000000),
      indicatorColor: const Color.fromARGB(255, 161, 215, 219),
      dividerColor: createMaterialColor(const Color(0xffcfc099)),
      brightness: Brightness.dark,
      hintColor: Colors.white70,
      primaryColor: createMaterialColor(const Color(0xff4d4d4d)),
      highlightColor: const Color(0xff6e6e6e),
      useMaterial3: false,
      // colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0xffefefef))).copyWith(secondary: createMaterialColor(Color(0xff383736))),
      primarySwatch:
          createMaterialColor(const Color.fromARGB(255, 255, 255, 255)),
    );

    ThemeData testare = ThemeData(
      fontFamily: 'CascadiaCode',
      splashColor: const Color(0xff000000),
      indicatorColor: const Color.fromARGB(255, 52, 68, 70),
      dividerColor: createMaterialColor(const Color(0xffcfc099)),
      brightness: Brightness.light,
      hintColor: Colors.white70,
      primaryColor: createMaterialColor(const Color(0xff4d4d4d)),
      highlightColor: const Color(0xff6e6e6e),
      // colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0xffefefef))).copyWith(secondary: createMaterialColor(Color(0xff383736))),
      primarySwatch:
          createMaterialColor(const Color.fromARGB(255, 255, 255, 255)),
    );

    return MaterialApp.router(
        //remove debug banner
        debugShowCheckedModeBanner: false,
        title: 'weRule',
        theme: temanormal,
        routerConfig: router);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  bool izzo = true;
  final String title;
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        // body:  DelegationBoxes()
        // body: NewProposal(org: orgs[0])
        // body: Members(org: orgs[2],)
        // body: Prelaunch()

        // body: DaoConfigurationDetails(
        //     type: "Quorum",
        //     proposalData: {"treasuryAddress": "s0a9d09vuj09cj09j4093qjf"})
        // body: RegistryProposalDetails(
        //     keyName: "thekeyofthething", value: "and here is the value")
        // // body: Explorer()
        );
  }
}
// 0xc5C77EC5A79340f0240D6eE8224099F664A08EEb

class WalletBTN extends StatefulWidget {
  const WalletBTN({super.key});
  @override
  State<WalletBTN> createState() => _WalletBTNState();
}

class _WalletBTNState extends State<WalletBTN> {
  final bool _isConnecting = false;
  @override
  void initState() {
    super.initState();
    // Load existing address
  }

  @override
  Widget build(BuildContext context) {
    // Access Human instance using Provider
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            metamask,
                            height: 100,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Download it from",
                        style:
                            TextStyle(fontFamily: "Roboto Mono", fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            launch("https://metamask.io/");
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
          // Since we're in a StatelessWidget, no need to call setState
          if (human.address == null) {
            setState(() {
              human.busy = true;
            });
            await human.signIn();
            setState(() {
              human.busy = false;
            });
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: ((context) => Explorer())));
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
                    Image.network(metamask, height: 27), // Adjust the URL
                    const SizedBox(width: 9),
                    const Text("Connect Wallet"),
                  ],
                )
              : Row(
                  children: [
                    FutureBuilder<Uint8List>(
                      future: generateAvatarAsync(hashString(human
                          .address!)), // Make your generateAvatar function return Future<Uint8List>
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: 40.0,
                            height: 40.0,
                            color: Colors.grey,
                          );
                        } else if (snapshot.hasData) {
                          print("generating");
                          return Image.memory(
                            snapshot.data!,
                            height: 40,
                            // fit: BoxFit.contain,
                          );
                        } else {
                          return Container(
                            width: 40.0,
                            height: 40.0,
                            color: const Color.fromARGB(
                                255, 116, 116, 116), // Error color
                          );
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
