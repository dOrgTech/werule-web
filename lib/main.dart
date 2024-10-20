import 'dart:math';
import 'dart:typed_data';
import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/screens/creator.dart';
import 'package:Homebase/utils/reusable.dart';
import 'package:Homebase/widgets/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:url_launcher/url_launcher.dart';
import 'entities/contractFunctions.dart';
import 'entities/org.dart';
import 'entities/project.dart';
import 'entities/token.dart';
import 'firebase_options.dart';
import 'prelaunch.dart';
import 'screens/dao.dart';
import 'screens/explorer.dart';
import 'screens/projectDetails.dart';
import 'screens/projects.dart';
import 'screens/users.dart';
import 'utils/functions.dart';
import 'utils/theme.dart';
import 'widgets/arbitrate.dart';
import 'widgets/daocard.dart';
import 'widgets/executeLambda.dart';
import 'widgets/membersList.dart';
import 'widgets/menu.dart';
import 'widgets/newGenericProject.dart';
import 'widgets/newProject.dart';
import 'widgets/sendfunds.dart';
import 'widgets/setParty.dart';
import 'entities/human.dart';
import 'utils/reusable.dart';
import 'screens/proposalDetails.dart';
import 'entities/proposal.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
String metamask="https://i.ibb.co/HpmDHg0/metamask.png";
List<User>? users;
List<Org> orgs=[];
List<Token> tokens=[];
List<Proposal>?proposals;

var daosCollection;
var pollsCollection;
var votesCollection;
var tokensCollection;
// Us3r us3r = Us3r(human: humans[0]);
var systemCollection = FirebaseFirestore.instance.collection('some');

persist() async {
  users=[];proposals=[];
  daosCollection=FirebaseFirestore.instance.collection("daos${Human().chain.name}");
  tokensCollection=FirebaseFirestore.instance.collection("tokens${Human().chain.name}");
  
  
  var daosSnapshot =await  daosCollection.get();
  var tokensSnapshot =await  tokensCollection.get();

  for (var doc in tokensSnapshot.docs){
    Token t = Token(name: doc.data()['name'], symbol: doc.data()['symbol'], decimals: doc.data()['decimals']);
    t.address = doc.data()['address'];
    tokens.add(t);
  }
  for (var doc in daosSnapshot.docs){
    print("we are doing this ");
    Org org=
      Org(name: doc.data()['name'],
      description: doc.data()['description'],
      govTokenAddress: doc.data()['govTokenAddress']
    );
    org.address=doc.data()['address'];
    org.symbol=doc.data()['symbol'];
    org.creationDate=(doc.data()['creationDate'] as Timestamp).toDate();
    org.govToken=Token(symbol: "XTZ", decimals: 3,name: "TOKEN");
    org.govTokenAddress = doc.data()['token'];
    org.votingDelay=doc.data()['votingDelay'];
    org.votingDuration=doc.data()['votingDuration'];
    org.executionAvailability=doc.data()['executionAvailability'];
    org.quorum=doc.data()['quorum'];
    org.supermajority=doc.data()['supermajority'];
    org.holders=doc.data()['holders'];
    org.treasuryMap=Map<String, String>.from(doc.data()['treasury']);
    orgs.add(org);
  }
  print("orgs length: "+orgs.length.toString());
}


void main() async {
  
 await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
 await persist();
 
  var systemSnapshot= await systemCollection.get(); 
  for (var doc in systemSnapshot.docs){
    print(doc.data());
  }
  
  runApp(
  ChangeNotifierProvider<Human>(
        create: (context) => Human(),
        child: const MyApp(),
      ));
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      if (ethereum==null){
       print("n-are metamask");
        Human().metamask=false;
    }else{
      print("are metamask");
        Human().metamask=true;
    }
    return MaterialApp(
      //remove debug banner
      debugShowCheckedModeBanner: false,
      title: 'Homebase',
      theme: ThemeData(
        fontFamily: 'CascadiaCode',
        splashColor: const Color(0xff000000),
        accentColor: const Color(0xff3bffdb),
        dividerColor: createMaterialColor(const Color(0xffcfc099)),
        brightness: Brightness.dark,
        hintColor: Colors.white70,
        primaryColor: createMaterialColor(const Color(0xff4d4d4d)),
        highlightColor: const Color(0xff6e6e6e),
        // colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0xffefefef))).copyWith(secondary: createMaterialColor(Color(0xff383736))),
        primarySwatch: createMaterialColor(const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: 
      Scaffold(body:
      //  DaoSetupWizard())
      // Center(child: TransferWidget(org: orgs[0],)))
      DAO(InitialTabIndex: 1, org:orgs[0]))
      // MyHomePage(title: 'Tezos homebase')),
    );
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
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        // body: ExecuteLambda()
        // body: Users()
        // body: Prelaunch()
        body:
         Explorer()
    
        );
  }
}


class WalletBTN extends StatefulWidget {
  const WalletBTN({super.key});

  @override
  State<WalletBTN> createState() => _WalletBTNState();
}

class _WalletBTNState extends State<WalletBTN> {
 bool _isConnecting=false;
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
              return  AlertDialog(
                content: Container(
                  height:260,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const Text("You need the a web3 wallet to sign into the app.",style: TextStyle(fontFamily: "Roboto Mono", fontSize: 16),),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(metamask,height: 100,),
                          const Icon(Icons.arrow_right_alt, size: 40,),
                          const SizedBox(width: 14,),
                           Image.network(
                              "https://i.ibb.co/sFqQxYP/Icon-maskable-192.png",
                              height: 70),
                            const SizedBox(width: 13,),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Text("Download it from",style: TextStyle(fontFamily: "Roboto Mono", fontSize: 16),),
                      const SizedBox(height: 10,),
                      TextButton(
                        onPressed: (){
                          launch("https://metamask.io/");
                        },
                        child: const Text("https://metamask.io/",style: TextStyle(fontFamily: "Roboto Mono", fontSize: 16),)),
                        
                    ],
                  ),
                
                ),

              );
            },
          );
        } else {
          // Since we're in a StatelessWidget, no need to call setState
        if ( human.address == null)
        {
        setState(() {  
        human.busy=true;
        });
         await human.signIn(); 
        setState(() {
          human.busy=false;
        });
        }
        else{
           Navigator.of(context).push(
        MaterialPageRoute(
          builder: ((context) =>
           const Explorer()
          )
      ));
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
                        future: generateAvatarAsync(hashString(human.address!)),  // Make your generateAvatar function return Future<Uint8List>
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: 40.0,
                              height: 40.0,
                              color: Colors.grey,
                            );
                          } else if (snapshot.hasData) {
                            print("generating");
                            return Image.memory(snapshot.data!);
                          } else {
                            return Container(
                              width: 40.0,
                              height: 40.0,
                              color: const Color.fromARGB(255, 116, 116, 116),  // Error color
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