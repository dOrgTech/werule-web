import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../screens/proposalDetails.dart';
import 'package:intl/intl.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/dao.dart';

class ProposalCard extends StatefulWidget {
  ProposalCard({super.key, required this.proposal, required this.org});
  Proposal proposal;
  String type = "proposals";
  int option = 0;
  Org org;

  @override
  State<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  late String status;
  Timer? _timer;

  @override
  void initState() {
    status = widget.proposal.stage.toString().split('.').last;
    // if (status == "noQuorum") {
    //   status = "no quorum";
    // }
    super.initState();
    if (!(status == "rejected") &&
        !(status == "executed") &&
        !(status == "expired")) {
      _startAutoUpdate();
    }
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      setState(() {}); // Triggers a rebuild to reflect the updated status
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.proposal.stage.toString().split('.').last;
    return widget.type == "proposals"
        ? proposals(context)
        : widget.type == "votedOn"
            ? votedOn(context)
            : Container();
  }

  Widget votedOn(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 78, 78, 78),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(width: 0.2, color: Color.fromARGB(255, 43, 43, 43))),
        child: InkWell(
          onTap: () {
            print("tapped on proposalCard");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DAO(
                          InitialTabIndex: 1,
                          org: widget.org,
                          proposalId: widget.proposal.id,
                        )));
          },
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Container(
                      width: 90, child: Text(widget.proposal.id.toString())),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1.0),
                    child: Text(
                      widget.proposal.name!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Container(
                    width: 180,
                    child: widget.option == 0
                        ? Icon(Icons.thumb_down,
                            color: Color.fromARGB(255, 238, 129, 121))
                        : Icon(Icons.thumb_up_sharp,
                            color: Color.fromARGB(255, 93, 223, 162))),
                SizedBox(
                    width: 150,
                    child: Center(
                        child: Text(
                      DateFormat('M/1d/yyyy HH:mm')
                          .format(widget.proposal.createdAt!),
                      style: TextStyle(fontSize: 14),
                    ))),
                SizedBox(
                    width: 150,
                    child: Center(
                        child: Text(
                      widget.proposal.type!,
                      style: TextStyle(fontSize: 14),
                    ))),
                Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 20,
                    width: 110,
                    child: Center(
                        child: widget.proposal.statusPill(
                            widget.proposal.statusHistory.entries
                                .reduce(
                                    (a, b) => a.value.isAfter(b.value) ? a : b)
                                .key,
                            context))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget proposals(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: () {
            print("tapped on proposalCard");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DAO(
                          InitialTabIndex: 1,
                          org: widget.org,
                          proposalId: widget.proposal.id,
                        )));
          },
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Container(
                      width: 90, child: Text(widget.proposal.id.toString())),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(widget.proposal.name!),
                  ),
                ),
                Container(
                    width: 230,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("0x3a84...3eds0"),
                        TextButton(onPressed: () {}, child: Icon(Icons.copy))
                      ],
                    )),
                SizedBox(
                    width: 150,
                    child: Center(
                        child: Text(DateFormat('M/d/yyyy HH:mm')
                            .format(widget.proposal.createdAt!)))),
                SizedBox(
                    width: 150,
                    child: Center(child: Text(widget.proposal.type!))),
                Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 20,
                    width: 110,
                    child: Center(
                        child: widget.proposal.statusPill(
                            widget.proposal.statusHistory.entries
                                .reduce(
                                    (a, b) => a.value.isAfter(b.value) ? a : b)
                                .key,
                            context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
