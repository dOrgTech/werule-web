import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homebase/entities/project.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';
import 'package:homebase/screens/projectDetails.dart';
import 'package:homebase/screens/projects.dart';
import 'package:homebase/utils/theme.dart';
import 'package:homebase/widgets/daocard.dart';
import 'package:homebase/widgets/executeLambda.dart';
import 'package:homebase/widgets/menu.dart';
import 'package:homebase/widgets/newProject.dart';

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
      // body: Explorer()
      body: ProjectDetails(project:   Project(
   name: "Engagement with another DAO" ,arbiter: "tz1T5kk65F9oZw2z1YV4osfcrX7eD5KtLj3c",
   description: "This is the description of the Project. Doesn't need to be super long cause we also link the Terms (on the right) and that should contain all...",
   client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
   link: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
   status:"Ongoing"
  ),)
    );
  }
}
