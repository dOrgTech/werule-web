import 'package:Homebase/widgets/fundProject.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:image/image.dart' as img;
import '../entities/proposal.dart';
import '../utils/reusable.dart';

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

  GovernanceTokenOperationDetails({required this.p});
  @override
  Widget build(BuildContext context) {
    String operationType = p.type!.split(" ").first;
    operationType = operationType[0].toUpperCase() +
        operationType.substring(1).toLowerCase();
    // String operationType = "Mint";
    String targetAddress =
        p.callDatas[0].keys.first.toString() ?? "targetaddressaiodnsinoasin";
    String amount = p.callDatas[0].values.first.toString() ?? "10000";
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Key:", p.callDatas[0].keys.first.toString()),
          SizedBox(height: 10),
          _buildDetailRow("Value:", p.callDatas[0].values.first.toString()),
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
