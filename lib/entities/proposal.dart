import 'dart:math';
import 'package:Homebase/entities/contractFunctions.dart';
import 'package:Homebase/entities/token.dart';
import 'package:Homebase/widgets/configProposal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/executeLambda.dart';
import '../widgets/newProject.dart';
import '../widgets/registryPropo.dart';
import '../widgets/transfer.dart';
import 'human.dart';
import 'org.dart';

var proposalTypes = {
  "Off-Chain Debate": "Post a thesis and have tokenized arguments around it",
  "Transfer Assets": "from the DAO Treasury\nto another account",
  "Edit Registry": "Change an entry\nor add a new one",
  "Contract Call": "Call any function\non any contract",
  "DAO Configuration":
      "Change the quorum,\nthe proposal durations\nor the treasury address",
};

var state;
var newProposalWidgets = {
  "New Project (arbitrated)": (Org org) => NewProject(org: org),
  "Offchain Poll": (Org org) => NotImplemented(),
  "Transfer Assets": (Org org, Proposal p, State state) =>
      TransferWidget(org: org, p: p, proposalsState: state),
  "Edit Registry": (Org org, Proposal p, State state) =>
      RegistryProposalWidget(org: org, p: p, proposalsState: state),
  "Add Lambda": (Org org) => NotImplemented(),
  "Remove Lambda": (Org org, State state) => NotImplemented(),
  "Contract Call": (Org org, Proposal p, State state) =>
      ContractInteractionWidget(p: p),
  "DAO Configuration": (Org org, Proposal p, State state) =>
      DaoConfigurationWidget(org: org, p: p, proposalsState: state),
  "Change Guardian": (Org org) => NotImplemented(),
  "Change DAO Delegate": (Org org) => NotImplemented()
};

class NotImplemented extends StatelessWidget {
  const NotImplemented({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 240,
        child: Center(
          child: Text("NOT IMPLEMENTED"),
        ));
  }
}

class Txaction {
  Txaction(
      {required this.recipient, required this.value, this.callData = "0x"});
  String hash = "none";
  String recipient;
  String value = "0";
  String callData = "0x";

  toJson() {
    return {
      'hash': hash,
      'recipient': recipient,
      'value': value,
      'callData': callData
    };
  }
}

enum StateInContract {
  Pending,
  Active,
  Canceled,
  Defeated,
  Succeeded,
  Queued,
  Expired,
  Executed
}

enum ProposalStatus {
  pending,
  active,
  passed,
  queued,
  executable,
  executed,
  expired,
  noQuorum,
  rejected
}

Map<String, String> statuses = {
  "Pending": "pending",
  "Active": "active",
  "Canceled": "canceled",
  "Defeated": "defeated",
  "Succeeded": "passed",
  "Queued": "queued",
  "Expired": "expired",
  "Executed": "executed",
};

// Map<String, String> statuses = {
//   "pending": "Pending",
//   "active": "Active",
//   "passed": "Succeeded",
//   "queued": "Queued",
//   "executable": "Queued",
//   "executed": "Executed",
//   "expired": "Expired",
//   "no quorum": "Defeated",
//   "rejected": "Defeated"
// };

class Proposal {
  String? id = "";
  late int inAppnumber;
  ProposalStatus? state;
  String hash = "";
  Org org;
  String? latestState;
  String? type;
  String? name = "Title of the proposal (max 80 characters)";
  String? description = "(no description)";
  String? author;
  double value = 0;
  List<String> targets = [];
  List<String> values = [];
  List callDatas = [];
  String? callData = "0x";
  DateTime? createdAt;
  DateTime? votingStarts;
  // String? status;
  DateTime? votingEnds;
  DateTime? executionStarts;
  DateTime? executionEnds;
  String status = "";
  Map<String, DateTime> statusHistory = {"pending": DateTime.now()};
  int turnoutPercent = 0;
  double turnout = 0;
  String inFavor = "0";
  String against = "0";
  int votesFor = 0;
  int votesAgainst = 0;
  String? externalResource = "(no link provided)";
  List<Txaction> transactions = [];
  List<Vote> votes = [];
  Proposal({required this.org, this.name});

  castVote(Vote v) async {
    var votesCollection = FirebaseFirestore.instance
        .collection("daos${Human().chain.name}")
        .doc(org.address)
        .collection("proposals")
        .doc(hash.toString())
        .collection("votes");
    votesCollection.add(v.toJson());

    if (v.option == 1) {
      votesFor++;
      inFavor =
          (BigInt.parse(inFavor) + BigInt.parse(v.votingPower)).toString();
    } else {
      votesAgainst++;
      against =
          (BigInt.parse(against) + BigInt.parse(v.votingPower)).toString();
    }
    var pollsCollection = FirebaseFirestore.instance
        .collection("daos${Human().chain.name}")
        .doc(org.address)
        .collection("proposals");
    pollsCollection.doc(hash.toString()).set(this.toJson());
    votes.add(v);
  }

  store() async {
    var pollsCollection = FirebaseFirestore.instance
        .collection("daos${Human().chain.name}")
        .doc(org.address)
        .collection("proposals");
    pollsCollection.doc(hash).set(toJson());
  }

  getVotesFromDAO() async {
    var theVotes = await getProposalVotes(this);
    if (theVotes.runtimeType == String) {
      print("some error from getProposalVotes $votes");
    }
    this.votesAgainst = theVotes[0];
    this.votesFor = theVotes[1];
  }

//////////////////////////////////

  Future<String> anotherStageGetter() async {
    int stateInContract = await getProposalState(this);
    String newStatus = StateInContract.values[stateInContract]
        .toString()
        .split(".")
        .last
        .toLowerCase();
    if (newStatus == "succeeded") {
      newStatus = "passed";
    }
    print("new status baby " + newStatus);
    DateTime start = statusHistory["pending"]!;
    Duration votingDelay = Duration(minutes: org.votingDelay ?? 0);
    Duration votingDuration = Duration(minutes: org.votingDuration ?? 0);
    Duration executionDelay = Duration(minutes: org.executionDelay ?? 0);
    DateTime activeStart = start.add(votingDelay);
    DateTime votingEnd = activeStart.add(votingDuration);
    DateTime now = DateTime.now();
    BigInt totalVotes = (BigInt.parse(inFavor) + BigInt.parse(against)) *
        BigInt.parse(pow(10, org.decimals!).toString());
    BigInt totalSupply = BigInt.parse(org.totalSupply ?? "1");
    double votePercentage = totalVotes * BigInt.from(100) / totalSupply;

    if (newStatus == "active") {
      state = ProposalStatus.active;
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
    }
    if (newStatus == "passed") {
      state = ProposalStatus.passed;
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
    }
    if (newStatus == "executed") {
      DateTime queuedTime =
          statusHistory['queued'] ?? now.subtract(const Duration(minutes: 23));
      DateTime executedTime =
          statusHistory['executed'] ?? now.subtract(const Duration(minutes: 3));
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
      statusHistory.addAll({"queued": queuedTime});
      statusHistory.addAll({"executable": queuedTime.add(executionDelay)});
      statusHistory.addAll({"executed": executedTime});
    }
    if (newStatus == "defeated") {
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      if (votePercentage < org.quorum) {
        statusHistory.addAll({"no quorum": votingEnd});
        newStatus = "no quorum";
      } else {
        statusHistory.addAll({"rejected": votingEnd});
        newStatus = "rejected";
      }
    }
    if (newStatus == "queued") {
      print("it is in fact queued");
      bool queuedTimeExists = false;
      DateTime? queuedTime = statusHistory['queued'];
      if (queuedTime != null) {
        queuedTimeExists = true;
      } else {
        queuedTime = now.subtract(const Duration(minutes: 13));
      }
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
      statusHistory.addAll({"queued": queuedTime});
      if (queuedTimeExists || now.isAfter(queuedTime.add(executionDelay))) {
        print("queued time exists and we are after execution delay");
        statusHistory.addAll({"executable": queuedTime.add(executionDelay)});
        newStatus = "executable";
      }
    }

    print("from another status getter we are returning status history:");
    print(statusHistory.toString());

    status = newStatus;
    return newStatus;
  }

  toJson() {
    return {
      'hash': hash,
      'type': type,
      'title': name,
      'description': description,
      'author': author,
      'calldata': callData,
      'createdAt': createdAt,
      'callDatas': callDatas,
      'targets': targets,
      'values': values,
      'statusHistory': statusHistory.map((key, value) {
        return MapEntry(key, Timestamp.fromDate(value));
      }),
      'turnoutPercent': turnoutPercent,
      'inFavor': inFavor,
      'against': against,
      'votesFor': votesFor,
      'votesAgainst': votesAgainst,
      'externalResource': externalResource,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
    };
  }

  ProposalStatus get stage {
    DateTime start = statusHistory["pending"]!;
    Duration votingDelay = Duration(minutes: org.votingDelay ?? 0);
    Duration votingDuration = Duration(minutes: org.votingDuration ?? 0);
    Duration executionDelay = Duration(minutes: org.executionDelay ?? 0);
    DateTime activeStart = start.add(votingDelay);
    DateTime votingEnd = activeStart.add(votingDuration);
    // DateTime executionDeadline = votingEnd.add(executionDelay);
    BigInt totalVotes = (BigInt.parse(inFavor) + BigInt.parse(against)) *
        BigInt.parse(pow(10, org.decimals!).toString());
    BigInt totalSupply = BigInt.parse(org.totalSupply ?? "1");
    double votePercentage = totalVotes * BigInt.from(100) / totalSupply;
    DateTime now = DateTime.now();
    ProposalStatus newStatus;
    if (statusHistory.containsKey("executed")) {
      DateTime executionTime = statusHistory['executed'] ?? DateTime.now();
      DateTime queueTime = statusHistory['executable'] ?? votingEnd;
      status = "executed";
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
      statusHistory.addAll({"executable": queueTime});
      statusHistory.addAll({status: executionTime});
      return ProposalStatus.executed;
    } else if (statusHistory.containsKey("executable")) {
      DateTime queueTime = statusHistory['executable'] ?? votingEnd;
      status = "executable";
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
      statusHistory.addAll({"executable": queueTime});
      if (DateTime.now().isAfter(queueTime.add(executionDelay))) {
        status = "expired";
        statusHistory.addAll({"expired": queueTime.add(executionDelay)});

        return ProposalStatus.expired;
      }
      return ProposalStatus.executable;
    }

    if (now.isBefore(activeStart)) {
      newStatus = ProposalStatus.pending;
    } else if (now.isBefore(votingEnd)) {
      newStatus = ProposalStatus.active;
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      status = "active";
      return newStatus;
    } else {
      // Voting has ended, check votes and quorum
      if (votePercentage < org.quorum) {
        newStatus = ProposalStatus.noQuorum;
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({"no quorum": votingEnd});
        status = "no quorum";
        return newStatus;
      } else if (BigInt.parse(inFavor) > BigInt.parse(against)) {
        newStatus = ProposalStatus.passed;
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({"passed": votingEnd});
        status = "passed";
        return newStatus;
      } else {
        // Proposal is rejected
        newStatus = ProposalStatus.rejected;
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({"rejected": votingEnd});
        status = "rejected";
        return newStatus;
      }
    }

    String latestStatus = statusHistory.entries
        .reduce((a, b) => a.value.isAfter(b.value) ? a : b)
        .key;
    return newStatus;
  }

  String getStatus() {
    DateTime start = statusHistory["pending"]!;
    Duration votingDelay = Duration(minutes: org.votingDelay ?? 0);
    Duration votingDuration = Duration(minutes: org.votingDuration ?? 0);
    Duration executionDelay = Duration(minutes: org.executionDelay ?? 0);

    DateTime activeStart = start.add(votingDelay);
    DateTime votingEnd = activeStart.add(votingDuration);
    DateTime executionDeadline = votingEnd.add(executionDelay);

    BigInt totalVotes = BigInt.parse(inFavor) + BigInt.parse(against);
    BigInt totalSupply = BigInt.parse(org.totalSupply ?? "1");
    double votePercentage = totalVotes * BigInt.from(100) / totalSupply;

    DateTime now = DateTime.now();
    String newStatus;
    if (statusHistory.containsKey("executed")) {
      DateTime executionTime = statusHistory['executed'] ?? executionDeadline;
      DateTime queueTime = statusHistory['executable'] ?? votingEnd;
      status = "executed";
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
      statusHistory.addAll({"executable": queueTime});
      statusHistory.addAll({status: executionTime});
      return "executed";
    } else if (statusHistory.containsKey("executable")) {
      DateTime queueTime = statusHistory['executable'] ?? votingEnd;
      status = "executable";
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      statusHistory.addAll({"passed": votingEnd});
      statusHistory.addAll({"executable": queueTime});
      return status;
    }

    if (now.isBefore(activeStart)) {
      newStatus = "pending";
    } else if (now.isBefore(votingEnd)) {
      newStatus = "active";
      statusHistory.clear();
      statusHistory.addAll({"pending": start});
      statusHistory.addAll({"active": activeStart});
      status = newStatus;
      return status;
    } else {
      // Voting has ended, check votes and quorum
      if (votePercentage < org.quorum) {
        newStatus = "no quorum";
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({"no quorum": votingEnd});
        status = newStatus;
        return newStatus;
      } else if ((BigInt.parse(inFavor) > BigInt.parse(against)) &&
          now.isBefore(executionDeadline)) {
        newStatus = "passed";
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({newStatus: votingEnd});
        status = newStatus;
        return newStatus;
      } else if ((BigInt.parse(inFavor) > BigInt.parse(against)) &&
          now.isAfter(executionDeadline)) {
        newStatus = "expired";
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({"passed": votingEnd});
        statusHistory.addAll({newStatus: executionDeadline});
        status = newStatus;
        return newStatus;
      } else {
        // Proposal is rejected
        newStatus = "rejected";
        statusHistory.clear();
        statusHistory.addAll({"pending": start});
        statusHistory.addAll({"active": activeStart});
        statusHistory.addAll({newStatus: votingEnd});
        status = newStatus;
        return newStatus;
      }
    }

    // Ensure status transitions and updates are correct
    String latestStatus = statusHistory.entries
        .reduce((a, b) => a.value.isAfter(b.value) ? a : b)
        .key;

    // Additional handling for the "executable" status
    if (latestStatus == "executable") {
      if (now.isBefore(executionDeadline)) {
        return "executable";
      } else {
        return "expired";
      }
    }

    return newStatus;
  }

  Duration? getRemainingTime() {
    DateTime start = statusHistory["pending"]!;
    Duration votingDelay = Duration(minutes: org.votingDelay ?? 0);
    Duration votingDuration = Duration(minutes: org.votingDuration ?? 0);
    Duration executionDelay = Duration(minutes: org.executionDelay ?? 0);
    DateTime activeStart = start.add(votingDelay);
    DateTime votingEnd = activeStart.add(votingDuration);
    // DateTime executionDeadline = votingEnd.add(executionDelay);

    DateTime now = DateTime.now();

    if (now.isBefore(activeStart)) {
      // Time remaining in "pending" status
      return activeStart.difference(now);
    } else if (now.isBefore(votingEnd)) {
      // Time remaining in "active" status
      return votingEnd.difference(now);
    } else if (stage == ProposalStatus.executable) {
      DateTime queuedTime = statusHistory["executable"]!;
      DateTime executionDeadline = queuedTime.add(executionDelay);
      // Time remaining in "executable" status
      return executionDeadline.difference(now);
    }

    // If the status is past "executable," return null
    return null;
  }

  List<Color> activecolors = [
    Color.fromARGB(255, 167, 147, 255),
    Color.fromARGB(255, 159, 150, 196),
  ];
  List<Color> pendingColors = [
    Color.fromARGB(255, 255, 248, 183),
    Color.fromARGB(255, 255, 251, 209),
  ];
  Widget statusPill(String status, context) {
    final Map<String, Widget> statuses = {
      "active": Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: activecolors),
            border: Border.all(
              width: 0.7,
              color: Color.fromARGB(255, 150, 126, 255),
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "ACTIVE",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          )),
      "pending": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(colors: pendingColors),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "PENDING",
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold),
            ),
          )),
      "passed": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border:
                Border.all(width: 0.5, color: Color.fromARGB(255, 18, 141, 45)),
            color: Color.fromARGB(255, 21, 50, 65),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "PASSED",
              style: TextStyle(color: Colors.white),
            ),
          )),
      "queued": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border:
                Border.all(width: 0.3, color: Color.fromARGB(255, 26, 26, 26)),
            color: Color.fromARGB(255, 184, 230, 233),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "QUEUED",
              style: TextStyle(color: Color.fromARGB(255, 41, 41, 41)),
            ),
          )),
      "defeated": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border:
                Border.all(width: 0.5, color: Color.fromARGB(255, 141, 18, 39)),
            color: Color.fromARGB(255, 46, 27, 27),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "DEFEATED",
              style: TextStyle(color: Color.fromARGB(255, 129, 122, 123)),
            ),
          )),
      "cancelled": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border:
                Border.all(width: 0.5, color: Color.fromARGB(255, 141, 18, 39)),
            color: Color.fromARGB(255, 46, 27, 27),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "CANCELLED",
              style: TextStyle(color: Color.fromARGB(255, 129, 122, 123)),
            ),
          )),
      "executable": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "EXECUTABLE",
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 99, 77),
                  fontWeight: FontWeight.bold),
            ),
          )),
      "executed": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Color.fromARGB(255, 63, 117, 86).withOpacity(0.5),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "EXECUTED",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          )),
      "expired": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Color.fromARGB(255, 202, 202, 202),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "EXPIRED",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          )),
      "no quorum": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Color.fromARGB(255, 82, 82, 82),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "NO QUORUM",
              style: TextStyle(color: Color.fromARGB(255, 230, 230, 230)),
            ),
          )),
      "rejected": Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Color.fromARGB(255, 87, 65, 64),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              "REJECTED",
              style: TextStyle(color: Color.fromARGB(255, 255, 233, 233)),
            ),
          )),
      "All": Text("All")
    };

    return statuses[status]!;
  }
}

class Vote {
  String voter;
  String? hash;
  String proposalID;
  int option;
  String votingPower;
  DateTime? castAt = DateTime.now();
  Vote(
      {required this.votingPower,
      required this.voter,
      required this.proposalID,
      required this.option,
      this.hash,
      required castAt});
  toJson() {
    return {
      'weight': votingPower,
      'cast': castAt,
      'voter': voter,
      'option': option,
      'hash': hash
    };
  }
}
