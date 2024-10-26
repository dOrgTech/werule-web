import 'dart:math';
import 'package:flutter/material.dart';

class VotingPowerWidget extends StatefulWidget {
  @override
  _VotingPowerWidgetState createState() => _VotingPowerWidgetState();
}

class _VotingPowerWidgetState extends State<VotingPowerWidget> {
  double _sliderValue = 1; // Starts at extreme left (100% of members)
  List<Member> members = [];
  int totalMembers = 0;
  double totalVotingPower = 0;
  double totalGovernanceTokenSupply = 0;

  @override
  void initState() {
    super.initState();
    // Generate mock data with more than 2 members
    members = getMembers();
    totalMembers = members.length;
    totalVotingPower = members.fold(0, (sum, member) => sum + member.votingWeight);
    totalGovernanceTokenSupply = totalVotingPower; // Assuming totalVotingPower equals total token supply
    // Sort members by votingWeight in descending order
    members.sort((a, b) => b.votingWeight.compareTo(a.votingWeight));
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage of members included based on the slider value
    double percentageOfMembers = (101 - _sliderValue); // Slider ranges from 1 to 100
    // Ensure at least one member is included
    int membersToInclude = max(1, ((percentageOfMembers / 100) * totalMembers).round());
    // Select the top members based on voting weight
    List<Member> selectedMembers = members.take(membersToInclude).toList();
    // Calculate cumulative voting power of selected members
    double cumulativeVotingPower = selectedMembers.fold(0, (sum, member) => sum + member.votingWeight);
    // Calculate percentages
    double membersPercentage = (membersToInclude / totalMembers) * 100;
    double votingPowerPercentage = (cumulativeVotingPower / totalGovernanceTokenSupply) * 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Slider without additional Text element
        Slider(
          value: _sliderValue,
          min: 1,
          max: 100,
          divisions: 99,
          label: 'Top ${percentageOfMembers.toInt()}% of Members',
          onChanged: (double value) {
            setState(() {
              _sliderValue = value;
            });
          },
        ),
        SizedBox(height: 20),
        // Only two Text elements with percentages in parentheses
        Text('Number of Members: $membersToInclude (${membersPercentage.toStringAsFixed(2)}%)'),
        Text('Voting Power: ${cumulativeVotingPower.toStringAsFixed(2)} (${votingPowerPercentage.toStringAsFixed(2)}%)'),
      ],
    );
  }

  List<Member> getMembers() {
    // Generate mock data with more than 2 members
    return List.generate(100, (index) {
      // Generate members with random votingWeight
      return Member(
        name: 'Member ${index + 1}',
        votingWeight: Random().nextDouble() * 100 + 1, // Ensure non-zero voting weight
      );
    });
  }
}

class Member {
  final String name;
  final double votingWeight;

  Member({required this.name, required this.votingWeight});
}
