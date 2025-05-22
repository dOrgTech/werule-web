import 'dart:math';
import 'package:flutter/material.dart';

import '../entities/org.dart';

class VotingPowerWidget extends StatefulWidget {
  Org org;
  VotingPowerWidget({super.key, required this.org});

  @override
  _VotingPowerWidgetState createState() => _VotingPowerWidgetState();
}

class _VotingPowerWidgetState extends State<VotingPowerWidget> {
  double _sliderValue = 1; // Starts at extreme left (100% of members)
  List<Bloke> members = [];
  int totalMembers = 0;
  double totalVotingPower = 0;
  double totalGovernanceTokenSupply = 0;
  String? selectedWidgetFeature = 'vote concentration';
  List<String> concentrationDropdown = [];
  @override
  void initState() {
    super.initState();
    // Generate mock data with more than 2 members
    members = getMembers() as List<Bloke>;
    totalMembers = members.length;
    totalVotingPower =
        members.fold(0, (sum, member) => sum + member.votingWeight);
    totalGovernanceTokenSupply =
        totalVotingPower; // Assuming totalVotingPower equals total token supply
    // Sort members by votingWeight in descending order
    members.sort((a, b) => b.votingWeight.compareTo(a.votingWeight));
    concentrationDropdown = [
      'vote concentration',
      '${widget.org.symbol} ownership',
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage of members included based on the slider value
    double percentageOfMembers =
        (101 - _sliderValue); // Slider ranges from 1 to 100
    // Ensure at least one member is included
    int membersToInclude =
        max(1, ((percentageOfMembers / 100) * totalMembers).round());
    // Select the top members based on voting weight
    List<Bloke> selectedMembers = members.take(membersToInclude).toList();
    // Calculate cumulative voting power of selected members
    double cumulativeVotingPower =
        selectedMembers.fold(0, (sum, member) => sum + member.votingWeight);
    // Calculate percentages
    double membersPercentage = (membersToInclude / totalMembers) * 100;
    double votingPowerPercentage =
        (cumulativeVotingPower / totalGovernanceTokenSupply) * 100;

    return Padding(
      padding: const EdgeInsets.only(right: 3.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30,
            constraints: const BoxConstraints(minWidth: 520),
            color: const Color.fromARGB(255, 224, 224, 224),
            child: Center(
                child: Row(
              children: [
                const Text(
                  "Drag slider to check ",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 15),
                ),
                DropdownButton<String>(
                  value: selectedWidgetFeature,
                  items: concentrationDropdown.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: value == selectedWidgetFeature
                              ? Colors.black
                              : Colors.grey, // Default color for dropdown items
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedWidgetFeature = value;
                    });
                  },
                  style: const TextStyle(
                      color: Colors.black), // Selected item text color
                  iconEnabledColor: Colors.black, // Dropdown arrow color
                ),
              ],
            )),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 520),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 63, 63, 63),
              border: Border.all(
                  color: const Color.fromARGB(255, 224, 224, 224), width: 0.6),
            ),
            height: 180,
            // width: MediaQuery.of(context).size.width*0.4,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "# of Members",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              membersToInclude.toString(),
                              style: const TextStyle(
                                  fontSize: 27, fontWeight: FontWeight.normal),
                            ),
                            Text(
                              "${membersPercentage.toStringAsFixed(2)}%",
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 120,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Voting Power",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              cumulativeVotingPower.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 27, fontWeight: FontWeight.normal),
                            ),
                            Text(
                              "${votingPowerPercentage.toStringAsFixed(2)}%",
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ]),
                const SizedBox(height: 18),

                SizedBox(
                  width: 430,
                  child: Slider(
                    value: _sliderValue,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    onChanged: (double value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Only two Text elements with percentages in parentheses
              ],
            ),
          ),
        ],
      ),
    );
  }

  List getMembers() {
    List<Bloke> members = [];
    widget.org.memberAddresses.forEach((key, Member value) {
      members.add(Bloke(
        personalBalance: double.parse(value.votingWeight!),
        name: 'Member ',
        votingWeight:
            double.parse(value.votingWeight!), // Ensure non-zero voting weight
      ));
    });
    return members;
  }
}

class Bloke {
  final String name;
  final double votingWeight;
  final double personalBalance;
  Bloke(
      {required this.personalBalance,
      required this.name,
      required this.votingWeight});
}
