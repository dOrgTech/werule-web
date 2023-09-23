import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homebase/entities/project.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';
import 'package:homebase/screens/projectDetails.dart';
import 'package:homebase/screens/projects.dart';
import 'package:homebase/utils/theme.dart';
import 'package:homebase/widgets/arbitrate.dart';
import 'package:homebase/widgets/daocard.dart';
import 'package:homebase/widgets/executeLambda.dart';
import 'package:homebase/widgets/menu.dart';
import 'package:homebase/widgets/newGenericProject.dart';
import 'package:homebase/widgets/newProject.dart';
import 'package:homebase/widgets/sendfunds.dart';
import 'package:homebase/widgets/setParty.dart';

import 'screens/proposalDetails.dart';

void main() {
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
      body: Explorer()
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
