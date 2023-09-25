import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homebase/entities/org.dart';
import 'package:homebase/entities/project.dart';
import 'package:homebase/entities/token.dart';
import 'package:homebase/entities/us3r.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';
import 'package:homebase/screens/projectDetails.dart';
import 'package:homebase/screens/projects.dart';
import 'package:homebase/screens/users.dart';
import 'package:homebase/utils/functions.dart';
import 'package:homebase/utils/theme.dart';
import 'package:homebase/widgets/arbitrate.dart';
import 'package:homebase/widgets/daocard.dart';
import 'package:homebase/widgets/executeLambda.dart';
import 'package:homebase/widgets/membersList.dart';
import 'package:homebase/widgets/menu.dart';
import 'package:homebase/widgets/newGenericProject.dart';
import 'package:homebase/widgets/newProject.dart';
import 'package:homebase/widgets/sendfunds.dart';
import 'package:homebase/widgets/setParty.dart';
import 'entities/human.dart';
import 'screens/proposalDetails.dart';

Us3r us3r = Us3r(human: humans[0]);


List<String>token_names = [
    "GreenLife", "CryptoMuseum", "SpaceYield", "DeFiTrust", "VirtuArt",
    "EtherRights", "Animalia", "TechSphere", "MediCare", "Sporty",
    "PureWater", "FoodChain", "WorldView", "CodeX", "SmartEdu",
    "GalaxyNet", "MusiQ", "SunPower", "ClimateFix", "SecurID",
    "GameZone", "LibraNet", "TravelX", "Futurist", "NanoPay",
    "Urbanize", "SkillUp", "FairTrade", "BioGen", "Mindful"
];

List<String>token_symbols = [
    "GLF", "CMU", "SYD", "DFT", "VUA",
    "ETHR", "ANM", "TSP", "MDC", "SPT",
    "PWT", "FDC", "WDV", "CDX", "SED",
    "GLX", "MSQ", "SNP", "CLF", "SCID",
    "GMZ", "LBR", "TVX", "FTS", "NPY",
    "UBZ", "SKP", "FRT", "BGN", "MDF"
];

List<String>org_descriptions = [
    "Sustainable living for a greener future. Let's make the planet a better place for everyone.",
    "Preserving digital art for eternity. A haven for artists and collectors alike.",
    "Maximizing yield in space agriculture. Food for Mars and beyond.",
    "Decentralized finance with a focus on trust and community building.",
    "A marketplace for virtual art, empowering artists in the digital age.",
    "Defending digital rights, from privacy to access to information.",
    "Dedicated to the conservation and well-being of endangered species worldwide.",
    "Innovating in technology for a smarter and more efficient future.",
    "Decentralized healthcare solutions that put patients in control.",
    "Revolutionizing sports through blockchain for fair play and transparent rewards.",
    "Clean water initiatives globally. Every drop counts.",
    "Using blockchain to ensure food safety and supply chain transparency.",
    "Mapping the world's data, one block at a time.",
    "An open-source coding community built for developers, by developers.",
    "Smart education solutions for remote and in-person learning.",
    "Facilitating communication between Earth and interstellar colonies.",
    "A platform for decentralized, on-demand music streaming.",
    "Investing in solar power to build a sustainable future.",
    "A global effort to mitigate climate change through blockchain.",
    "Secure your identity and transactions in a decentralized world.",
    "A reward-based gaming ecosystem that's fair and transparent.",
    "Building balanced financial systems for a stable economy.",
    "Travel experiences tokenized for ease and accessibility.",
    "Funding and promoting future tech, from AI to space travel.",
    "Fast, efficient nano payments with no middlemen.",
    "Urban planning and development in the age of blockchain.",
    "Upskill your life with courses and resources on blockchain.",
    "A marketplace for fair trade and ethical consumerism.",
    "Genetic research for the betterment of healthcare and agriculture.",
    "Promoting mindfulness and well-being through decentralized apps."
];



List<Token>tokens=[
  Token(address: generateContractAddress(), name: "Autonet", symbol: "ATN", decimals: 5),
  Token(address: generateContractAddress(), name: "Quantum Church", symbol: "QTC", decimals: 5),
  Token(address: generateContractAddress(), name: "Lots of Trees", symbol: "LOT", decimals: 4),
  Token(address: generateContractAddress(), name: "Dem Gyals", symbol: "DGY", decimals: 4),
  Token(address: generateContractAddress(), name: "New World Order", symbol: "NWO", decimals: 4),
];

List<Org>orgs=[
  Org(address: generateContractAddress(), name: "Autonet", token: tokens[0], description: "Decentralized training and inference for AI models."),
  Org(address: generateContractAddress(), name: "Quantum Church", token: tokens[1], description: "In quarks we trust"),
  Org(address: generateContractAddress(), name: "Lots of Trees", token: tokens[2], description: "Raising funds for planting more of these woody things into the grownd and possibly making things better for all lifeforms."),
  Org(address: generateContractAddress(), name: "Dem Gyals", token: tokens[3], description: "We out here now."),
  Org(address: generateContractAddress(), name: "New World Order", token: tokens[4], description: "If not us, who? The dutch? Not likely. They barely reach 500m with their digging equipment."),
];


List<Human>humans=[
  Human(
    pic:add1,
    address: generateWalletAddress(),
    balances: {
      tokens[0]:700400,tokens[1]:971,tokens[3]:380000
    },
    lastActive: DateTime.now().subtract(Duration(hours: 34))
  ),
   Human(
    pic:add2,
    address: generateWalletAddress(),
    balances: {tokens[1]:620823,tokens[0]:110,tokens[3]:40000},
    lastActive: DateTime.now().subtract(Duration(hours: 134))
  ),
  Human(pic: add1,
    address: generateWalletAddress(),
    balances: {tokens[0]:700400,tokens[1]:971,tokens[3]:380000},
    lastActive: DateTime.now().subtract(Duration(hours: 84)),
  )
];

void main() {
  for(var i=5;i<token_names.length;i++){
    tokens.add(Token(address: generateContractAddress(), name: token_names[i], symbol: token_symbols[i], decimals: 5));
    orgs.add(Org(address: generateContractAddress(), name: token_names[i], token: tokens[i], description: org_descriptions[i]));
  }
 

List<Human> additionalHumans = [];

List<int> lastActiveHours = List.generate(50, (index) => Random().nextInt(200) + 1);

for (int i = 0; i < 50; i++) {
  String address = generateWalletAddress();
  int numBalances = Random().nextInt(10) + 1; // At least 1, at most 10
  Map<Token, double> balances = {};

  for (int j = 0; j < numBalances; j++) {
    balances[tokens[Random().nextInt(30)]] = (Random().nextInt(1000000) + 100).toDouble();
  }

  DateTime lastActive = DateTime.now().subtract(Duration(hours: lastActiveHours[i]));

  humans.add(
    Human(address: address, balances: balances, lastActive: lastActive, pic: '')
  );
}


  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //remove debug banner
      debugShowCheckedModeBanner: false,
      title: 'Homebase',
      theme: ThemeData(
        fontFamily: 'CascadiaCode',
      splashColor: Color(0xff000000),
      accentColor:Color(0xff3bffdb),
      dividerColor: createMaterialColor(Color(0xffcfc099)),
      brightness: Brightness.dark,
      hintColor: Colors.white70,
      primaryColor: createMaterialColor(Color(0xff4d4d4d)),
      highlightColor: Color(0xff6e6e6e), 
      // colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0xffefefef))).copyWith(secondary: createMaterialColor(Color(0xff383736))),
        primarySwatch:createMaterialColor(Color.fromARGB(255, 255, 255, 255)),
      ),
      home: const MyHomePage(title: 'Tezos homebase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
 
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      // body: ExecuteLambda()
      body: Users()
      // body: SendFunds()
      // body: Explorer()
  //     body: Arbitrate(
  //       project:  Project( 
  //  name: "P2P IRC Protocol" ,arbiter: "tz49jro65F9oZw2z1YV4osfcrX7eD5KtAl2e",
  //  description: "If you miss an appointment to voluntarily turn yourself in, they don't usually ask twice so it would be wise to arrive in a timely fashion on this one.",
  //  client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
  //  terms: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
  //  status:"Disputed"
  //       ))
  //     // body: Center(child: SendFunds())
  //     // body:NewGenericProject()
  // //     body: ProjectDetails(project:  Project( 
  // //  name: "P2P IRC Protocol" ,arbiter: "tz49jro65F9oZw2z1YV4osfcrX7eD5KtAl2e",
  // //  description: "If you miss an appointment to voluntarily turn yourself in, they don't usually ask twice so it would be wise to arrive in a timely fashion on this one.",
  // //  client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
  // //  terms: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
  // //  status:"Ongoing"
  // // ),)
    );
  }
}
