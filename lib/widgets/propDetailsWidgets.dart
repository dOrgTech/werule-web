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
              getShortAddress(p.targets[0]),
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
  final String type;
  final Map<String, dynamic> proposalData;

  DaoConfigurationDetails({required this.type, required this.proposalData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.3),
        color: Color.fromARGB(255, 28, 28, 28),
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
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDetailsSection(type),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(String type) {
    switch (type) {
      case "Quorum":
        return _buildQuorumDetails();
      case "Voting Delay":
        return _buildDurationDetails("Duration", proposalData['duration']);
      case "Voting Period":
        return _buildDurationDetails("Duration", proposalData['duration']);
      case "Switch Treasury":
        return _buildTreasuryDetails(proposalData['treasuryAddress']);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildQuorumDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Parameter:", "Quorum"),
        _buildRow("Value:", "${proposalData['quorum']}%"),
      ],
    );
  }

  Widget _buildDurationDetails(String title, Map<String, int> duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Parameter:", title),
        _buildRow("Days:", "${duration['days']}"),
        _buildRow("Hours:", "${duration['hours']}"),
        _buildRow("Minutes:", "${duration['minutes']}"),
      ],
    );
  }

  Widget _buildTreasuryDetails(String treasuryAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Parameter:", "Treasury Address"),
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
              child: Text(
                treasuryAddress,
                style: TextStyle(color: Colors.white),
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

// Helper widget for development
class DaoConfigurationDetailsSwitcher extends StatefulWidget {
  @override
  _DaoConfigurationDetailsSwitcherState createState() =>
      _DaoConfigurationDetailsSwitcherState();
}

class _DaoConfigurationDetailsSwitcherState
    extends State<DaoConfigurationDetailsSwitcher> {
  String selectedType = "Quorum";

  Map<String, dynamic> proposalData = {
    'quorum': 10,
    'duration': {'days': 0, 'hours': 2, 'minutes': 30},
    'treasuryAddress': "0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF"
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedType,
          items: ["Quorum", "Voting Delay", "Voting Period", "Switch Treasury"]
              .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedType = value!;
            });
          },
        ),
        SizedBox(height: 20),
        DaoConfigurationDetails(type: selectedType, proposalData: proposalData),
      ],
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
