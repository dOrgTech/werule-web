import 'package:Homebase/utils/reusable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../screens/creator.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import 'dart:typed_data';

String add1 = "https://i.ibb.co/2WbL5nC/add1.png";
String add2 = "https://i.ibb.co/6rmksXk/add2.png";
List<String> userPics = [add1, add2];

class MembersList extends StatelessWidget {
  MembersList({super.key, required this.org});
  Org org;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("idaos${Human().chain.name}")
            .doc(org.address)
            .collection("members")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Show a loading indicator
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return Text(
                "Members are being indexed. Check back later or use Remix to interact with the DAO.");
          }

          final docs = snapshot.data!.docs;
          for (var doc in docs) {
            Member m = Member(address: doc.data()['address']);
            m.personalBalance = doc.data()['personalBalance'];
            m.votingWeight = "0";
            List<String> proposalsCreatedHashes =
                List<String>.from(doc.data()['proposalsCreated'] ?? []);
            List<String> proposalsVotedHashes =
                List<String>.from(doc.data()['proposalsVoted'] ?? []);
            m.proposalsCreated = org.proposals
                .where((proposal) =>
                    proposalsCreatedHashes.contains(proposal.hash))
                .toList();
            m.proposalsVoted = org.proposals
                .where(
                    (proposal) => proposalsVotedHashes.contains(proposal.hash))
                .toList();
            m.lastSeen = doc.data()['lastSeen'] != null
                ? (doc.data()['lastSeen'] as Timestamp).toDate()
                : null;
            org.memberAddresses[m.address.toLowerCase()] = m;
            m.delegate = doc.data()['delegate'] ?? "";
            if (!(m.delegate == "")) {
              if (!org.memberAddresses.keys
                  .contains(m.delegate.toLowerCase())) {
                Member delegate = Member(address: m.delegate);
                org.memberAddresses[delegate.address.toLowerCase()] = delegate;
                delegate.constituents.add(m);
              } else {
                org.memberAddresses[m.delegate.toLowerCase()]!.constituents
                    .add(m);
              }
            }
          }

          for (Member m in org.memberAddresses.values) {
            if (m.delegate == m.address) {
              for (Member constituent in m.constituents) {
                m.votingWeight = (BigInt.parse(m.votingWeight!) +
                        BigInt.parse(constituent.personalBalance!))
                    .toString();
              }
            }
          }
          List<TableRow> tableRows = [];
          for (Member m in org.memberAddresses.values) {
            tableRows.add(MemberTableRow(m, context));
          }
          return Column(children: [
            Table(
              border: TableBorder.all(color: Colors.transparent),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(2.4),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Container(
                      height: 22,
                      color: const Color.fromARGB(0, 76, 175, 79),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 75),
                        child: Text("Address"),
                      ),
                    ),
                    Container(
                        height: 35,
                        color: const Color.fromARGB(0, 76, 175, 79),
                        child: const Center(
                            child: Text(
                          "Voting\nWeight",
                          textAlign: TextAlign.center,
                        ))),
                    Container(
                        height: 42,
                        color: const Color.fromARGB(0, 76, 175, 79),
                        child: Center(
                            child: Text("Personal\n${org.symbol!} Balance",
                                textAlign: TextAlign.center))),
                    Container(
                        height: 42,
                        color: const Color.fromARGB(0, 76, 175, 79),
                        child: Center(
                            child: Text("Proposals\nCreated",
                                textAlign: TextAlign.center))),
                    Container(
                        height: 42,
                        color: const Color.fromARGB(0, 76, 175, 79),
                        child: const Center(
                            child: Text("Proposals\nVoted",
                                textAlign: TextAlign.center))),
                  ],
                ),
              ],
            ),
            Opacity(
                opacity: 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 29.0),
                  child: Divider(),
                )),
            Table(
                border: TableBorder.all(color: Colors.transparent),
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(2.4),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: tableRows)
          ]);
        });
  }
}

class MemberTableRow extends TableRow {
  BuildContext? context;
  MemberTableRow(member, context)
      : super(
          children: <Widget>[
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 35),
                child: Row(
                  children: [
                    FutureBuilder<Uint8List>(
                      future: generateAvatarAsync(hashString(member
                          .address)), // Make your generateAvatar function return Future<Uint8List>
                      builder: (context, snapshot) {
                        // Future.delayed(Duration(milliseconds: 500));
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Theme.of(context).canvasColor,
                            ),
                            width: 50.0,
                            height: 50.0,
                          );
                        } else if (snapshot.hasData) {
                          return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0)),
                              child: Image.memory(snapshot.data!));
                        } else {
                          return Container(
                            width: 50.0,
                            height: 50.0,
                            color: Theme.of(context).canvasColor, // Error color
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      member.address,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: member.address));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Center(
                                child: Text("Address copied to clipboard"))));
                      },
                      child: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.votingWeight?.toString() ?? "N/A"),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.personalBalance ?? "N/A"),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.proposalsCreated.length.toString()),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.proposalsVoted.length.toString()),
              ),
            ),
          ],
        );
}
