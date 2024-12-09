import 'dart:convert';
import 'dart:typed_data';
import 'dart:typed_data';
import 'dart:typed_data';
import 'package:Homebase/entities/definitions.dart';
import 'package:Homebase/widgets/fundProject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
// import '../entities/contractFunctions.dart';
import '../entities/human.dart';
import '../entities/proposal.dart';
import '../utils/reusable.dart';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';
import 'package:collection/collection.dart'; // For ListEquality

class TokenTransfer {
  final String amount;
  final String token;
  final String address;
  final String explorerUrl;
  final String hash;
  bool done = false;

  TokenTransfer(this.amount, this.token, this.address, this.explorerUrl,
      this.hash, this.done);
}

class TokenTransferListWidget extends StatelessWidget {
  Proposal p;

  List<TokenTransfer> tokenTransfers = [];

  TokenTransferListWidget({
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    for (Txaction t in p.transactions) {
      tokenTransfers.add(TokenTransfer(t.value, "XTZ", t.recipient,
          "explorerURL", "fashsaodisahodi", false));
    }
    ;
    return ListView.builder(
      itemCount: tokenTransfers.length,
      itemBuilder: (context, index) {
        final transfer = tokenTransfers[index];
        return SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Amount and Token Symbol
                Text(
                  '${transfer.amount} ${transfer.token}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),

                // Arrow indicating "to"
                Icon(Icons.arrow_forward, size: 20),

                const SizedBox(width: 8),

                // Avatar image generated from address hash
                FutureBuilder<Uint8List>(
                  future: generateAvatarAsync(transfer.hash),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ); // Placeholder while loading
                    } else if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        width: 40,
                        height: 40,
                      ); // Render the generated avatar
                    } else {
                      return SizedBox(
                        width: 40,
                        height: 40,
                      ); // Placeholder if there's an error
                    }
                  },
                ),
                SizedBox(width: 16),
                // Address
                Expanded(
                  child: Text(
                    transfer.address,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ContractCall extends StatelessWidget {
  Proposal p;
  ContractCall({super.key, required this.p});
  @override
  Widget build(BuildContext context) {
    List<Widget> params = [];
    (p.callDatas[0]["params"]).forEach((key, value) {
      params.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 6),
            Container(
                constraints: BoxConstraints(maxWidth: 370),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.2,
                    ),
                    color: Color.fromARGB(255, 28, 28, 28)),
                child: Column(
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: 370),
                      width: double.infinity,
                      color: Colors.grey,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                              text: value[0],
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 40, 40, 40)),
                              children: [
                                const TextSpan(text: "  -  "),
                                TextSpan(
                                  text: value[1],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 5, 56, 66),
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(key),
                    ),
                  ],
                )),
            SizedBox(width: 10),
          ],
        ),
      ));
    });
    return Container(
      padding: EdgeInsets.only(top: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          children: [
            const SizedBox(
                width: 120,
                child: Align(
                    alignment: Alignment.centerRight, child: Text("calling:"))),
            SizedBox(width: 9),
            Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.2,
                    ),
                    color: Color.fromARGB(255, 28, 28, 28)),
                child: Text(p.callDatas[0]["endpoint"]))
          ],
        ),
        Row(
          children: [
            const SizedBox(
                width: 120,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("on contract:"))),
            SizedBox(width: 9),
            Text(
              getShortAddress(p.targets[0].toString()),
              // "ndwq89hdp197hdqpo98shdp9q8723hp98qh9"),
              style: TextStyle(fontSize: 14),
            ),
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: p.targets[0]));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 1),
                      content: SizedBox(
                          height: 40,
                          child: Center(
                              child: Text("Address copied to clipboard")))));
                },
                child: Icon(Icons.copy))
          ],
        ),
        SizedBox(height: 5),
        Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
                width: 120,
                child: Align(
                    alignment: Alignment.centerRight, child: Text("params:")))),
        ...params
      ]),
    );
  }
}

class DaoConfigurationDetails extends StatelessWidget {
  final Proposal p;

  DaoConfigurationDetails({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          // border: Border.all(color: Colors.grey, width: 0.3),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("Change"),
                ),
              ),
              SizedBox(width: 8),
              Text(
                p.type!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDetailsSection(context, p.type!),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(context, String type) {
    switch (type) {
      case "quorum":
        return _buildQuorumDetails();
      case "voting delay":
        return _buildDurationDetails(
            "new voting delay", p.callDatas[0]['duration']);
      case "voting period":
        return _buildDurationDetails("Duration", p.callDatas[0]['duration']);
      case "treasury":
        return _buildTreasuryDetails(
            context, p.callDatas[0]['treasuryAddress']);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildQuorumDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Parameter:", "new quorum (percentage)"),
        _buildRow("Value:", "${p.callDatas[0]['quorum']}%"),
      ],
    );
  }

  Widget _buildDurationDetails(String title, String totalMinutes) {
    final totalMinutesInt = int.parse(totalMinutes);
    final days = totalMinutesInt ~/ (24 * 60);
    final hours = (totalMinutesInt % (24 * 60)) ~/ 60;
    final minutes = totalMinutesInt % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Parameter:", title),
        _buildRow("Days:", "$days"),
        _buildRow("Hours:", "$hours"),
        _buildRow("Minutes:", "$minutes"),
      ],
    );
  }

  Widget _buildTreasuryDetails(context, String treasuryAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Parameter:", "new treasury (address)"),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("Address:"),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.2),
                color: Colors.grey[900],
              ),
              child: Row(
                children: [
                  Text(
                    treasuryAddress,
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                duration: Duration(seconds: 1),
                                content: Center(
                                    child:
                                        Text('Address copied to clipboard'))));
                      },
                      child: Icon(Icons.copy))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(label),
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.2),
              color: Colors.grey[900],
            ),
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class GovernanceTokenOperationDetails extends StatelessWidget {
  final Proposal p;
  List<dynamic> decodeFunctionParameters(
      ContractFunction functionAbi, String hexString) {
    // Convert the hex string to bytes
    Uint8List dataBytes = hexToBytes(hexString);

    // Remove the 4-byte function selector
    Uint8List dataWithoutSelector = dataBytes.sublist(4);

    // Initialize decoding variables
    int offset = 0;
    List<dynamic> decodedParams = [];

    for (var param in functionAbi.parameters) {
      // Decode each parameter based on its type
      if (param.type is StringType) {
        // String type decoding (dynamic)
        BigInt paramOffset =
            bytesToInt(dataWithoutSelector.sublist(offset, offset + 32));
        int paramOffsetInt = paramOffset.toInt();

        // Decode length of the string
        BigInt length = bytesToInt(
            dataWithoutSelector.sublist(paramOffsetInt, paramOffsetInt + 32));
        int lengthInt = length.toInt();

        // Extract the actual string data
        Uint8List stringBytes = dataWithoutSelector.sublist(
            paramOffsetInt + 32, paramOffsetInt + 32 + lengthInt);
        decodedParams.add(String.fromCharCodes(stringBytes));
      } else if (param.type is AddressType) {
        // Address type decoding (last 20 bytes of the first 32-byte slot)
        Uint8List addressBytes =
            dataWithoutSelector.sublist(offset + 12, offset + 32);
        decodedParams.add(
            EthereumAddress.fromHex(bytesToHex(addressBytes)).hex..toString());
      } else if (param.type is UintType) {
        // Uint type decoding (entire 32 bytes)
        Uint8List uintBytes = dataWithoutSelector.sublist(offset, offset + 32);
        decodedParams.add(bytesToInt(uintBytes).toString());
      } else {
        throw UnsupportedError(
            "Unsupported parameter type: ${param.type.runtimeType}");
      }

      // Move to the next 32-byte slot
      offset += 32;
    }

    return decodedParams;
  }

  GovernanceTokenOperationDetails({required this.p});
  @override
  Widget build(BuildContext context) {
    String operationType = p.type!.split(" ").first;
    operationType = operationType[0].toUpperCase() +
        operationType.substring(1).toLowerCase();
    // String operationType = "Mint";
    List params = [];
    if (operationType == "Mint") {
      params = decodeFunctionParameters(mintGovTokensDef, p.callDatas[0]);
    }
    print("=======decoding params=========");
    print(params);
    String targetAddress = params[0];
    String amount = params[1];
    return Container(
      padding: EdgeInsets.all(16.0),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey, width: 0.3),
      //   color: Color.fromARGB(255, 28, 28, 28),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(operationType + " " + p.org.symbol! + " tokens"),
          SizedBox(height: 30),
          _buildDetailRow(
              operationType == "Mint" ? "To Address:" : "From Address",
              targetAddress),
          SizedBox(height: 10),
          _buildDetailRow("Amount:", amount),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(label),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.2),
                color: Colors.grey[900],
              ),
              child: Text(
                value,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistryProposalDetails extends StatelessWidget {
  Proposal p;

  RegistryProposalDetails({required this.p});
  decodeParams(hexString) {
    Uint8List dataBytes = hexToBytes(hexString);
    Uint8List dataWithoutSelector = dataBytes.sublist(4);
    Uint8List param1OffsetBytes = dataWithoutSelector.sublist(0, 32);
    Uint8List param2OffsetBytes = dataWithoutSelector.sublist(32, 64);
    BigInt param1Offset = bytesToInt(param1OffsetBytes);
    BigInt param2Offset = bytesToInt(param2OffsetBytes);
    int param1OffsetInt = param1Offset.toInt();
    Uint8List param1LengthBytes =
        dataWithoutSelector.sublist(param1OffsetInt, param1OffsetInt + 32);
    BigInt param1Length = bytesToInt(param1LengthBytes);
    int param1LengthInt = param1Length.toInt();
    Uint8List param1DataBytes = dataWithoutSelector.sublist(
        param1OffsetInt + 32, param1OffsetInt + 32 + param1LengthInt);
    String param1Data = String.fromCharCodes(param1DataBytes);
    int param2OffsetInt = param2Offset.toInt();
    Uint8List param2LengthBytes =
        dataWithoutSelector.sublist(param2OffsetInt, param2OffsetInt + 32);
    BigInt param2Length = bytesToInt(param2LengthBytes);
    int param2LengthInt = param2Length.toInt();
    Uint8List param2DataBytes = dataWithoutSelector.sublist(
        param2OffsetInt + 32, param2OffsetInt + 32 + param2LengthInt);
    String param2Data = String.fromCharCodes(param2DataBytes);

    return [param1Data, param2Data];
  }

  Widget operation(values) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Key:", values[0]),
          SizedBox(height: 10),
          _buildDetailRow("Value:", values[1]),
        ],
        // children: [Text("Key: ${p.callDatas[0].toString()}")],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert hex string to bytes
    List<Widget> operations = [];
    for (var callData in p.callDatas) {
      List<String> values = decodeParams(p.callDatas[0]);
      operations.add(operation(values));
    }

    return ListView(children: operations);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(label),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.2),
                color: Colors.grey[900],
              ),
              child: Text(
                " " + value,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElectionResultBar extends StatefulWidget {
  final BigInt inFavor;
  final BigInt against;

  const ElectionResultBar({
    required this.inFavor,
    required this.against,
  });

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

  @override
  void didUpdateWidget(covariant ElectionResultBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger re-animation if inFavor or against values change
    if (widget.inFavor != oldWidget.inFavor ||
        widget.against != oldWidget.against) {
      _animateBar();
    }
  }

  void _animateBar() {
    setState(() {
      BigInt totalVotes = widget.inFavor + widget.against;
      if (totalVotes > BigInt.zero) {
        _inFavorWidth = widget.inFavor.toDouble() / totalVotes.toDouble();
        _againstWidth = widget.against.toDouble() / totalVotes.toDouble();
      } else {
        // No votes case: both widths should be zero
        _inFavorWidth = 0;
        _againstWidth = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BigInt totalVotes = widget.inFavor + widget.against;

    // Handle case with no votes
    if (totalVotes == BigInt.zero) {
      return Container(
        height: 20,
        width: double.infinity, // Use full width available
        color: Colors.grey[700], // Grey color to represent no votes
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double barWidth = constraints.maxWidth;
        double maxDuration = 800; // Maximum total duration in milliseconds

        // The larger portion determines the animation duration
        double maxPercentage = max(_inFavorWidth, _againstWidth);
        int durationInMillis = (maxDuration * maxPercentage).toInt();

        return Row(
          children: [
            AnimatedContainer(
              width: barWidth * _inFavorWidth, // Use the actual widget width
              height: 20, // Height of the bar
              color: const Color.fromARGB(255, 0, 196, 137),
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
            AnimatedContainer(
              width: barWidth * _againstWidth, // Use the actual widget width
              height: 20,
              color: const Color.fromARGB(255, 134, 37, 30),
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
          ],
        );
      },
    );
  }
}

class ParticipationBar extends StatefulWidget {
  double turnout; // value between 0 and 100
  final double quorum; // value between 0 and 100

  ParticipationBar({required this.turnout, required this.quorum, Key? key})
      : super(key: key);

  @override
  _ParticipationBarState createState() => _ParticipationBarState();
}

class _ParticipationBarState extends State<ParticipationBar> {
  double _turnoutFraction = 0;

  @override
  void initState() {
    super.initState();
    widget.turnout = widget.turnout * 100;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateTurnout();
    });
  }

  @override
  void didUpdateWidget(covariant ParticipationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.turnout != oldWidget.turnout ||
        widget.quorum != oldWidget.quorum) {
      _animateTurnout();
    }
  }

  void _animateTurnout() {
    setState(() {
      _turnoutFraction = widget.turnout / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    double quorumFraction = widget.quorum / 100;

    return LayoutBuilder(
      builder: (context, constraints) {
        double barWidth = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              height: 20,
              width: barWidth,
              color: Colors.grey[700],
            ),
            AnimatedContainer(
              width: barWidth * _turnoutFraction,
              height: 20,
              color: Colors.grey[400],
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            ),
            Positioned(
              left: quorumFraction * barWidth,
              child: Container(
                height: 15,
                width: 6,
                color: Colors.black,
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
    var votesCollection = FirebaseFirestore.instance
        .collection("idaos${Human().chain.name}")
        .doc(widget.p.org.address)
        .collection("proposals")
        .doc(widget.p.id.toString())
        .collection("votes");
    print("creating the collection");
    var votesSnapshot = await votesCollection.get();
    print("length of votesSnapshot.docs ${votesSnapshot.docs.length}");
    widget.p.votes.clear();
    for (var doc in votesSnapshot.docs) {
      print("adding a vote");
      widget.p.votes.add(Vote(
        votingPower: doc.data()['weight'],
        voter: doc.data()['voter'],
        hash: "0x" +
            doc
                .data()['hash']
                .bytes
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(),
        proposalID: widget.p.id!,
        option: doc.data()['option'],
        castAt: (doc.data()['cast'] != null)
            ? (doc.data()['cast'] as Timestamp).toDate()
            : null,
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
      child: FutureBuilder<void>(
        future: _votesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors
            return Center(
                child: Text("Error loading votes: ${snapshot.error}"));
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
                    DataColumn(label: Text("Cast At")),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: widget.p.votes.map((vote) {
                    return DataRow(cells: [
                      DataCell(Row(
                        children: [
                          Text(getShortAddress(vote.voter!)),
                          const SizedBox(width: 8),
                          TextButton(
                              child: Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: vote.voter!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Center(
                                            child: Text(
                                                'Address copied to clipboard'))));
                              })
                        ],
                      )),
                      DataCell(Container(
                          child: vote.option == 0
                              ? const Icon(Icons.thumb_down,
                                  color: Color.fromARGB(255, 238, 129, 121))
                              : const Icon(Icons.thumb_up_sharp,
                                  color: Color.fromARGB(255, 93, 223, 162)))),
                      DataCell(Text(vote.votingPower.toString())),
                      DataCell(Text(DateFormat("yyyy-MM-dd – HH:mm")
                          .format(vote.castAt!))),
                      DataCell(
                        TextButton(
                            onPressed: () => launch(
                                "${Human().chain.blockExplorer}/tx/${vote.hash}"),
                            child: Icon(Icons
                                .open_in_new)), // You can add onTap functionality here later
                      )
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

class ProposalLifeCycleWidget extends StatelessWidget {
  Proposal p;
  ProposalLifeCycleWidget({required this.p});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (100 + 40 * p.statusHistory.keys.length)
          .toDouble(), // Adjust the height as needed
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(43),
              itemCount: p.statusHistory.length,
              itemBuilder: (context, index) {
                final sortedKeys = p.statusHistory.keys.toList()
                  ..sort((a, b) =>
                      p.statusHistory[a]!.compareTo(p.statusHistory[b]!));
                final status = sortedKeys[index];
                final date = p.statusHistory[status]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 9.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      p.statusPill(status, context),
                      Text(DateFormat.yMMMd().add_jm().format(date)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
