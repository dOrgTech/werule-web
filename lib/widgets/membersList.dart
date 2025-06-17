import 'package:Homebase/services/blockscout.dart';
import 'package:Homebase/utils/functions.dart';
import 'package:Homebase/utils/reusable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
// import '../screens/creator.dart';
import '../entities/org.dart';

String add1 = "https://i.ibb.co/2WbL5nC/add1.png";
String add2 = "https://i.ibb.co/6rmksXk/add2.png";
List<String> userPics = [add1, add2];

class MembersList extends StatefulWidget {
  const MembersList({super.key, required this.org});
  final Org org;

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  Future<void>? _fetchFuture;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    if (widget.org.memberAddresses.isEmpty) {
      _fetchFuture = _fetchMembers();
    }
  }

  Future<void> _fetchMembers() async {
    var balances= await getHolders(widget.org.govTokenAddress!);
    for (var entry in balances.entries) {
      String address = entry.key.toString();
      String balance = entry.value.toString();
      if (widget.org.memberAddresses.containsKey(address)) {
        widget.org.memberAddresses[address]!.personalBalance = balance;
      } else {
        Member m = Member(address: address);
        m.personalBalance = balance;
        widget.org.memberAddresses[address] = m;
      }
    }


    // final querySnap = await FirebaseFirestore.instance
    //     .collection("idaos${Human().chain.name}")
    //     .doc(widget.org.address)
    //     .collection("members")
    //     .get();

    // for (var doc in querySnap.docs) {
    //   Member m = Member(address: doc.data()['address']);
    //   // Keep personalBalance as a String to avoid breaking existing code
    //   m.personalBalance = doc.data()['personalBalance'].toString();
    //   List<String> proposalsCreatedHashes =
    //       List<String>.from(doc.data()['proposalsCreated'] ?? []);
    //   List<String> proposalsVotedHashes =
    //       List<String>.from(doc.data()['proposalsVoted'] ?? []);
    //   m.proposalsCreated = widget.org.proposals
    //       .where((proposal) => proposalsCreatedHashes.contains(proposal.hash))
    //       .toList();
    //   m.proposalsVoted = widget.org.proposals
    //       .where((proposal) => proposalsVotedHashes.contains(proposal.hash))
    //       .toList();
    //   m.lastSeen = doc.data()['lastSeen'] != null
    //       ? (doc.data()['lastSeen'] as Timestamp).toDate()
    //       : null;
    //   m.delegate = doc.data()['delegate'] ?? "";
    //   m.constituentsAddresses =
    //       List<String>.from(doc.data()['constituents'] ?? []);
    //   widget.org.memberAddresses[m.address.toLowerCase()] = m;
    // }
  }

  void _changePage(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.org.memberAddresses.isNotEmpty) {
      return _buildTable();
    }

    return FutureBuilder<void>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (widget.org.memberAddresses.isEmpty) {
          return Column(
            children: [
              const Text(
                  "No members found.\n\n\nRecently added members can take up to one hour to get indexed and show up here"),
              const SizedBox(height: 20),
             

           
            ],
          );
        }

        return _buildTable();
      },
    );
  }

  Widget _buildTable() {
    final allMembers = widget.org.memberAddresses.values.toList();
    // Sort by personalBalance descending, parsing from String to BigInt
    // allMembers.sort((a, b) => BigInt.parse(b.personalBalance!)
    //     .compareTo(BigInt.parse(a.personalBalance!)));

    final totalPages = (allMembers.length / _pageSize).ceil();
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, allMembers.length);
    final pageMembers = allMembers.sublist(startIndex, endIndex);

    List<TableRow> tableRows = pageMembers
        .map((m) => MemberTableRow(m, context, widget.org.decimals))
        .toList();

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
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Center(
                  child: Text(
                    "Personal\n${widget.org.symbol!} Balance ▼",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
         
            ],
          ),
        ],
      ),
      const Opacity(
        opacity: 0.5,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 29.0),
          child: Divider(),
        ),
      ),
      Table(
        border: TableBorder.all(color: Colors.transparent),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(2.4),
          1: FlexColumnWidth(),
          
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
      const SizedBox(height: 70),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 1 ? () => _changePage(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed:
                _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
          ),
          Text('Page $_currentPage of $totalPages'),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage < totalPages
                ? () => _changePage(_currentPage + 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < totalPages
                ? () => _changePage(totalPages)
                : null,
          ),
        ],
      )
    ]);
  }
}

class MemberTableRow extends TableRow {
  BuildContext? context;
  MemberTableRow(member, context, decimals)
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
                child: Text(
                    "${BigInt.parse(member.personalBalance.toString()) ~/ BigInt.from(10).pow(decimals)}" ??
                        "N/A"),
              ),
            ),
         
          ],
        );
}
