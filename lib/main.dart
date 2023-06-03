import 'package:flutter/material.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';
import 'package:homebase/utils/theme.dart';
import 'package:homebase/widgets/daocard.dart';
import 'package:homebase/widgets/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      appBar: TopMenu(),
      body: DAO()
      // body: Explorer()
    );
  }
}
