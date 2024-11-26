import 'package:Homebase/entities/contractFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import '../entities/human.dart';
import '../entities/token.dart';
import '../main.dart';
import '../widgets/gameOfLife.dart';
import '../widgets/menu.dart';
import '../entities/org.dart';
import '../widgets/daocard.dart';
import '../widgets/footer.dart';
import 'creator.dart';

class Explorer extends StatefulWidget {
  Explorer({super.key});
  Widget? game;
  @override
  State<Explorer> createState() => _ExplorerState();

  Stream getDaos() async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection("idaos${Human().chain.name}")
        .snapshots()) {
      orgs = [];
      for (var doc in snapshot.docs) {
        print("we are doing this ");
        try {
          Org org = Org(
              name: doc.data()['name'],
              description: doc.data()['description'],
              govTokenAddress: doc.data()['govTokenAddress']);
          org.address = doc.data()['address'];
          org.symbol = doc.data()['symbol'];
          org.creationDate = (doc.data()['creationDate'] as Timestamp).toDate();
          org.govToken = Token(
              symbol: org.symbol!, decimals: org.decimals, name: org.name);
          org.govTokenAddress = doc.data()['token'];
          org.proposalThreshold = doc.data()['proposalThreshold'];
          org.votingDelay = doc.data()['votingDelay'];
          org.treasuryAddress = doc.data()['treasuryAddress'];
          org.registryAddress = doc.data()['registryAddress'];
          org.votingDuration = doc.data()['votingDuration'];
          org.executionDelay = doc.data()['executionDelay'];
          org.quorum = doc.data()['quorum'];
          org.decimals = doc.data()['decimals'];
          org.holders = doc.data()['holders'];
          org.treasuryMap = Map<String, String>.from(doc.data()['treasury']);
          org.registry = Map<String, String>.from(doc.data()['registry']);
          org.totalSupply = doc.data()['totalSupply'];
          orgs.add(org);
        } catch (e) {
          print("could not go " + e.toString());
        }
      }

      // Optionally include a message or other logic here
      print("New data received: ${snapshot.docs.length} documents");
      yield "yielding"; // Pass processed data to the widget
    }
  }
}

class _ExplorerState extends State<Explorer> {
  @override
  void initState() {
    widget.game = Container();
    super.initState();
  }

  @override
  void dispose() {
    widget.game = SizedBox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          TextButton(onPressed: () {}, child: Icon(Icons.help_center)),
      appBar: const TopMenu(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Opacity(opacity: 0.03, child: GameOfLife()),
            Container(
              alignment: Alignment.topCenter,
              child: StreamBuilder<void>(
                  stream: widget.getDaos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    print("building explorer" + orgs.length.toString());
                    List<Widget> daos = [];
                    for (var org in orgs) {
                      print("adding a dao");
                      daos.add(DAOCard(org: org as Org));
                    }
                    return ListView(
                      // Start of ListView
                      shrinkWrap: true, // Set this property to true
                      children: [
                        Column(
                          // Start of Column
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Set this property to center the items horizontally
                          mainAxisSize: MainAxisSize
                              .min, // Set this property to make the column fit its children's size vertically
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 80,
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 1200),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              1200
                                          ? 550
                                          : MediaQuery.of(context).size.width *
                                              0.5,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(width: 0.1),
                                          ),
                                          prefixIcon: Icon(Icons.search),
                                          hintText:
                                              'Search by DAO Name or Token Symbol',
                                          // other properties
                                        ),
                                        // other properties
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Row(
                                      children: [
                                        Text(orgs.length.toString() + " DAOs"),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.black)),
                                          height: 40,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                                body:
                                                                    DaoSetupWizard())));
                                              },
                                              style: TextButton.styleFrom(
                                                  disabledBackgroundColor:
                                                      Colors.grey,
                                                  elevation: 5,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .indicatorColor
                                                          .withOpacity(0.92)),
                                              child: Text(
                                                "Create DAO",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                    fontFamily: 'CascadiaCode',
                                                    fontSize: 19,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              alignment: Alignment.topCenter,
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 1200),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.start,
                                children: daos as List<Widget>,
                              ),
                            )
                          ],
                        ), // End of Column
                        const SizedBox(height: 83),
                        // other widgets
                      ],
                    );
                  }), // End of ListView
            ),
          ],
        ),
      ),
    );
  }
}
