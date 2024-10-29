import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gojs/gojs.dart';

class VotingPowerWidget extends StatefulWidget {
  @override
  _VotingPowerWidgetState createState() => _VotingPowerWidgetState();
}

class _VotingPowerWidgetState extends State<VotingPowerWidget> {
  double _sliderValue = 1; // Starts at extreme left (100% of members)
  List<Bloke> members = [];
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
    List<Bloke> selectedMembers = members.take(membersToInclude).toList();
    // Calculate cumulative voting power of selected members
    double cumulativeVotingPower = selectedMembers.fold(0, (sum, member) => sum + member.votingWeight);
    // Calculate percentages
    double membersPercentage = (membersToInclude / totalMembers) * 100;
    double votingPowerPercentage = (cumulativeVotingPower / totalGovernanceTokenSupply) * 100;

    return Padding(
      padding: const EdgeInsets.only(right:3.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30,
             constraints: BoxConstraints(minWidth: 520),
             child: Center(child: Text("Drag slider to check vote concentration", style: TextStyle(fontWeight: FontWeight.w600, color:Colors.black, fontSize: 17),)),
             color: Color.fromARGB(255, 224, 224, 224),
          ),
          Container(
             constraints: BoxConstraints(minWidth: 520),
            decoration: BoxDecoration(
              color:Color.fromARGB(255, 63, 63, 63),
              border: Border.all(color:Color.fromARGB(255, 224, 224, 224), width: 0.6), 
             
            ),
            height: 180,
            // width: MediaQuery.of(context).size.width*0.4,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Container(
                     decoration: const BoxDecoration(
    
                     ),
                     child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("# of Members" , style: TextStyle(
                              fontSize: 16,
                              ),),
                              const SizedBox(height: 10,),
                              Text(membersToInclude.toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              Text("${membersPercentage.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),),
                          ],
                        ),
                   ),
                   SizedBox(width: 120,),
                      Container(
                       
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Voting Power" , style: TextStyle(
                              fontSize: 16,
                              ),),
                              const SizedBox(height: 10,),
                              Text(cumulativeVotingPower.toStringAsFixed(2), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              Text("${votingPowerPercentage.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),),
                          ],
                        ),
                      ),
                ]),
               const SizedBox(height:18),
               
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

  List<Bloke> getMembers() {
    // Generate mock data with more than 2 members
    return List.generate(100, (index) {
      // Generate members with random votingWeight
      return Bloke(
        name: 'Member ${index + 1}',
        votingWeight: Random().nextDouble() * 100 + 1, // Ensure non-zero voting weight
      );
    });
  }
}

class Bloke {
  final String name;
  final double votingWeight;

  Bloke({required this.name, required this.votingWeight});
}
