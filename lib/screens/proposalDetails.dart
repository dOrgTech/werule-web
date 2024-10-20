import 'package:Homebase/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:math' as math;
import '../entities/human.dart';
import '../entities/proposal.dart';
import '../utils/reusable.dart';
import '../widgets/menu.dart';
import '../widgets/propDetailsWidgets.dart';
import 'dao.dart';
class ProposalDetails extends StatefulWidget {
  int id;
  ProposalDetails({super.key, required this.id, required this.p});
  Proposal p;
  @override
  State<ProposalDetails> createState() => _ProposalDetailsState();
}

class _ProposalDetailsState extends State<ProposalDetails> {
  @override
  Widget build(BuildContext context) {



    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Column( // Start of Column
          crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
          mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
          children: [
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("< Back to all proposals"))),
            const SizedBox(height: 10),
            Container(
              height: 240,
              color: Theme.of(context).cardColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.p.name! ,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: ElevatedButton(
                                style: TextButton.styleFrom(
                                  side: BorderSide(
                                      width: 0.2,
                                      color: Theme.of(context).hintColor),
                                ),
                                onPressed: () {},
                                child: const Text("Drop Proposal",
                                    style: TextStyle(fontSize: 12))),
                          )
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            border: Border.all(width: 0.5, color: Colors.white12)),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                             Text(widget.p.type!+" proposal"),
                            const SizedBox(width: 20),
                            Opacity(
                              opacity: 0.7,
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Theme.of(context).indicatorColor,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(3),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Text(
                                      "ACTIVE",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 129),
                   //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Posted By: "),
                                 Text(
                                  widget.p.author!,
                                  style: TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 2),
                                TextButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: widget.p.author));
                                 ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Center(child: Text('Address copied to clipboard'))));
                                },
                               child: const Icon(Icons.copy)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Created At: "),
                                 Text(
                                    widget.p.createdAt!.toLocal().toString(),
                                  style: TextStyle(fontSize: 11),
                                ),
                              SizedBox(width: 50,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                    ],
                  ),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                        SizedBox(height: 45),
                         Container(
                            constraints: const BoxConstraints(
                              maxWidth: 450,
                            ),
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                             widget.p.description!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                            SizedBox(
                          height: 30,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Discussion: "),
                                 Text(
                                 widget.p.externalResource!,
                                  style: TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 2),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(widget.p.externalResource! as Uri);
                                    },
                                    child: const Icon(Icons.open_in_new)),
                              ],
                            ),
                          ),
                        ),
                       ],
                     ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: 280,
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 48.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.hourglass_bottom,
                                  size: 50,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Time left to vote",
                                      style: TextStyle(
                                          color: Theme.of(context).indicatorColor,
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    const SizedBox(height: 10),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 28.0),
                                      child: Text(
                                        "0d 11h 19m (2137 blocks)",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 70),
                          Padding(
                            padding: const EdgeInsets.only(left: 48.0),
                            child: SizedBox(
                              width: 360,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      style: const ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(0.0),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.teal)),
                                      onPressed: () {},
                                      child: const SizedBox(
                                          width: 120,
                                          height: 40,
                                          child: Center(
                                              child: Text("Support")))),
                                  const Spacer(),
                                  ElevatedButton(
                                      onPressed: () {},
                                      style: const ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(0.0),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.redAccent)),
                                      child: const SizedBox(
                                          width: 120,
                                          height: 40,
                                          child: Center(
                                              child: Text("Oppose"))))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 280,
                  constraints: const BoxConstraints(
                    maxWidth: 680,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 19, left: 28.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "12 Votes",
                                    style: TextStyle(
                                        fontSize: 17,
                                        color:
                                            Theme.of(context).indicatorColor,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                ElevatedButton(
                                    onPressed: () {
                                      showDialog(context: context, builder: (context)=>
                                        AlertDialog(content: VotesModal(p: widget.p,),)
                                      );
                                    },
                                    child: const Text("View"))
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(width: 34),
                                Icon(Icons.circle, color: Colors.teal),
                                SizedBox(width: 10),
                                SizedBox(
                                    child: Text("Support",
                                        )),
                                SizedBox(width: 13),
                                Text("14305000 (49.41%)", style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                Spacer(),
                                Icon(Icons.circle, color: Colors.redAccent),
                                SizedBox(width: 10),
                                SizedBox(
                                    child: Text("Oppose",
                                       )),
                                SizedBox(width: 13),
                                Text("14781100 (51.59%)", style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                SizedBox(width: 73)
                              ],
                            ),
                          ),
                          const SizedBox(height: 13),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 28.0),
                            child: SizedBox(
                                height: 10,
                                width: double.infinity,
                               child: ElectionResultBar(inFavor: 900, against: 300))
                          ),
                          const SizedBox(height: 43),
                            Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(width: 34),
                               
                                SizedBox(
                                    child: Text("Turnout:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal))),
                                SizedBox(width: 13),
                                Text("14305000 (49.41%)",style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                Spacer(),
                               
                                SizedBox(
                                    child: Text("Quorum met",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900))),
                                SizedBox(width: 73)
                              ],
                            ),
                          ),
                          const SizedBox(height: 13),
                           Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 28.0),
                            child: SizedBox(
                                height: 10,
                                width: double.infinity,
                             child:  ParticipationBar(totalVoters: 10000, turnout: 4310, quorum: 20))
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 60),
            Align(
                alignment: Alignment.topLeft,
                child: const Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Text("Execution details:"),
                )),
            const SizedBox(height: 12),
            Container(
                height: 352,
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: const BoxDecoration(color: Color(0xff121416)),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: 
                    TokenTransferListWidget(
                      p: widget.p,
                    )
                  )
                  )
          ],
        ),
      ),
    );
  }
}



class ElectionResultBar extends StatefulWidget {
  final int inFavor;
  final int against;
  const ElectionResultBar({
    Key? key,
    required this.inFavor,
    required this.against,
  }) : super(key: key);

  @override
  _ElectionResultBarState createState() => _ElectionResultBarState();
}

class _ElectionResultBarState extends State<ElectionResultBar> {
  double _inFavorWidth = 0;
  double _againstWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateBar();
    });
  }

  void _animateBar() {
    setState(() {
      int totalVotes = widget.inFavor + widget.against;
      _inFavorWidth = widget.inFavor / totalVotes;
      _againstWidth = widget.against / totalVotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = widget.inFavor + widget.against;
    double inFavorPercentage = widget.inFavor / totalVotes;
    double againstPercentage = widget.against / totalVotes;

    return LayoutBuilder(
      builder: (context, constraints) {
        double barWidth = constraints.maxWidth;
        double maxDuration = 800; // Maximum total duration in milliseconds

        // The larger portion determines the animation duration
        double maxPercentage = inFavorPercentage > againstPercentage ? inFavorPercentage : againstPercentage;
        int durationInMillis = (maxDuration * maxPercentage).toInt();

        return Row(
          children: [
            AnimatedContainer(
              width: barWidth * _inFavorWidth, // Use the actual widget width
              height: 20, // Height of the bar
              color: Colors.teal,
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
            AnimatedContainer(
              width: barWidth * _againstWidth, // Use the actual widget width
              height: 20,
              color: Colors.red,
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
          ],
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';

class ParticipationBar extends StatefulWidget {
  final int totalVoters;
  final int turnout;
  final double quorum; // Provided as a percentage, e.g., 50.0 for 50%

  const ParticipationBar({
    Key? key,
    required this.totalVoters,
    required this.turnout,
    required this.quorum,
  }) : super(key: key);

  @override
  _ParticipationBarState createState() => _ParticipationBarState();
}

class _ParticipationBarState extends State<ParticipationBar> {
  double _turnoutWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateTurnout();
    });
  }

  void _animateTurnout() {
    setState(() {
      _turnoutWidth = widget.turnout / widget.totalVoters; // Calculate the turnout percentage
    });
  }

  @override
  Widget build(BuildContext context) {
    double turnoutPercentage = (widget.turnout / widget.totalVoters) * 100;
    double quorumPosition = widget.quorum / 100; // Quorum as a fraction (0 to 1)

    return LayoutBuilder(
      builder: (context, constraints) {
        double barWidth = constraints.maxWidth; // Get the actual width of the widget

        return Stack(
          children: [
            Container(
              height: 20,
              width: barWidth, // Total width based on available space
              color: Colors.grey[700], // Dark grey for total possible votes
            ),
            AnimatedContainer(
              width: barWidth * _turnoutWidth, // Use the actual widget width for turnout
              height: 20,
              color: Colors.grey[400], // Light grey for turnout
              duration: Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            ),
            Positioned(
              left: quorumPosition * barWidth, // Calculate quorum position relative to bar width
              child: Container(
                height: 15, // Height of the quorum marker
                width: 2, // Small vertical line for quorum
                color: Colors.black, // Marker color
              ),
            ),
          ],
        );
      },
    );
  }
}




class VotesModal extends StatefulWidget {
  final Proposal p;
  VotesModal({required this.p, super.key});

  @override
  State<VotesModal> createState() => _VotesModalState();
}

class _VotesModalState extends State<VotesModal> {
  late Future<void> _votesFuture;

  Future<void> getVotes() async {
    var votesCollection = FirebaseFirestore
        .instance
        .collection("daos${Human().chain.name}")
        .doc(widget.p.org.address)
        .collection("proposals")
        .doc(widget.p.id.toString())
        .collection("votes");

    var votesSnapshot = await votesCollection.get();
    widget.p.votes.clear();
    for (var doc in votesSnapshot.docs) {
      widget.p.votes.add(Vote(
        votingPower: doc.data()['weight'],
        voter: doc.id,
        proposalID: widget.p.id.toString(),
        option: doc.data()['option'],
        castAt: (doc.data()['cast'] != null) ? (doc.data()['cast'] as Timestamp).toDate() : null,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _votesFuture = getVotes(); // Initialize the Future in initState
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: 650,
      child: FutureBuilder<void>(
        future: _votesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while fetching data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors
            return Center(child: Text("Error loading votes: ${snapshot.error}"));
          } else {
            // Data is ready, display the votes in a table
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Voter')),
                    DataColumn(label: Text('Option')),
                    DataColumn(label: Text('Weight')),
                    DataColumn(label: Text('Cast At')),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: widget.p.votes.map((vote) {
                    return DataRow(cells: [
                      DataCell(Text(vote.voter!)),
                      DataCell(Text(vote.option.toString())),
                      DataCell(Text(vote.votingPower.toString())),
                      DataCell(Text(formatDateTime(vote.castAt))),
                      DataCell(Icon(Icons.open_in_new)), // You can add onTap functionality here later
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}


