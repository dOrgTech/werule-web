import 'dart:async';

import 'package:Homebase/utils/reusable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import 'package:go_router/go_router.dart';

class ProposalCard extends StatefulWidget {
  const ProposalCard({super.key, required this.proposal, required this.org});
  final Proposal proposal;
  final Org org;

  @override
  State<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  late String status;
  Timer? _timer;

  @override
  void initState() {
    status = widget.proposal.stage.toString().split('.').last;
    if (status == "noQuorum") {
      status = "no quorum";
    }
    super.initState();
    if (!(status == "rejected") &&
        !(status == "executed") &&
        !(status == "expired")) {
      _startAutoUpdate();
    }
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {}); // Triggers a rebuild to reflect the updated status
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    status = widget.proposal.stage.toString().split('.').last;
    if (status == "noQuorum") {
      status = "no quorum";
    }
    // Always return the 'proposals' layout
    return proposals(context);
  }

  // Widget votedOn(context) { // REMOVED votedOn method
  // } // Ensure this method is fully removed or commented out

  Widget proposals(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: () {
            context.go("/${widget.org.address!}/${widget.proposal.id}");
          },
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 40),
                    child: SizedBox(
                        width: 40,
                        child: TextButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: widget.proposal.id.toString()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Center(
                                          child: Text(
                                              'Proposal ID copied to clipboard'))));
                            },
                            child: const Icon(Icons.copy)))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(widget.proposal.name!),
                  ),
                ),
                SizedBox(
                    width: 230,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getShortAddress(widget.proposal.author!),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 235, 235, 235)),
                        ),
                      ],
                    )),
                SizedBox(
                    width: 150,
                    child: Center(
                        child: Text(
                      DateFormat('M/d/yyyy HH:mm')
                          .format(widget.proposal.createdAt!),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 235, 235, 235)),
                    ))),
                SizedBox(
                    width: 120,
                    child: Center(
                        child: Text(
                      widget.proposal.type!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ))),
                Container(
                    padding: const EdgeInsets.only(right: 10),
                    height: 20,
                    width: 110,
                    child: Center(
                        child: widget.proposal
                            .statusPill(widget.proposal.status, context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
