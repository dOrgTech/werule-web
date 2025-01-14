import 'package:Homebase/screens/dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import '../entities/org.dart';
import '../utils/reusable.dart';

// class ArgumentCard extends StatelessWidget {
//   final Argument argument;
//   final Function(Argument) onTap;

//   const ArgumentCard({
//     Key? key,
//     required this.argument,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//       child: ListTile(
//         title: Text(argument.content),
//         subtitle: Text('Pro: ${argument.proCount} | Con: ${argument.conCount}'),
//         onTap: () => onTap(argument),
//       ),
//     );
//   }
// }

List<Color> debateColors = [
  Color.fromARGB(255, 220, 205, 255),
  Color.fromARGB(255, 150, 187, 196),
];

class DebateCard extends StatelessWidget {
  Debate debate;
  Org org;
  DebateCard({super.key, required this.org, required this.debate});

  @override
  Widget build(BuildContext context) {
    return proposals(context);
  }

  Widget proposals(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DAO(
                      org: org,
                      InitialTabIndex: 1,
                      proposalHash: debate.hash,
                    )));
          },
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 40),
                    child: Container(
                        width: 40,
                        child: TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: debate.hash.toString()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Center(
                                          child: Text(
                                              'Debate ID copied to clipboard'))));
                            },
                            child: Icon(Icons.copy)))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(debate.title),
                  ),
                ),
                Container(
                    width: 230,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getShortAddress(debate.rootArgument.author),
                          style: TextStyle(
                              color: Color.fromARGB(255, 235, 235, 235)),
                        ),
                      ],
                    )),
                SizedBox(
                    width: 150,
                    child: Center(
                        child: Text(
                      DateFormat('M/d/yyyy HH:mm').format(DateTime.now()),
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 235, 235, 235)),
                    ))),
                SizedBox(
                    width: 120,
                    child: Center(
                        child: Text(
                      "debate",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ))),
                SizedBox(width: 30),
                Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 22,
                    width: 80,
                    child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: debateColors),
                            border: Border.all(
                              width: 0.7,
                              color: const Color.fromARGB(255, 150, 126, 255),
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(3),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              "OPEN",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 46, 46, 46)),
                            ),
                          )),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
