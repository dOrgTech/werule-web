import 'package:homebase/entities/token.dart';
import 'dart:math';
import '../main.dart';
import 'org.dart';

class Human {
  Human(
      {this.address,
      this.balances,
      this.lastActive,
      this.icon,
      required this.pic}) {
    final random = Random();
    final numActions = random.nextInt(28) +
        3; // Generate a random number of actions between 3 and 30
    // An array of possible contracts
    final actions = <Action>[]; // Create an empty list to hold the actions
    // Generate random actions and add them to the list
    for (var i = 0; i < numActions; i++) {
      final type = random.nextDouble() < 0.7 // 60% chance of selecting "Vote"
          ? 'Vote'
          : [
              'Proposal Creation: Transfer',
              'Proposal Creation: Mint',
              'Proposal Creation: Swap',
              'Proposal Creation: Add Function',
              'Function Execution: Arbitration',
              'Function Execution: Mint',
              'Function Execution: Set Party',
            ][random.nextInt(3)]; // 40% chance of selecting another type
      final contract =
          orgs[random.nextInt(orgs.length)]; // Randomly select a contract
      final time = DateTime.now().subtract(Duration(
          days: random.nextInt(
              60))); // Generate a random time between now and two months ago
      actions.add(Action(type: type, contract: contract.name, time: time));
    }
    // Sort the actions by time (oldest to newest)
    actions.sort((a, b) => a.time.compareTo(b.time));
    this.actions = actions; 
    memberships = [];
    if (balances != null) {
      for (final token in balances!.keys) {
        for (final org in orgs) {
          if (org.address == token.address) {
            memberships!.add(org);
            break;
          }
        }
      }
    }
  }

  String pic;
  String? address;
  Map<Token, double>? balances;
  DateTime? lastActive;
  String? icon;
  List<Action>? actions;
  List<Org>? memberships;
}

class Action {
  Action({required this.type, required this.contract, required this.time});

  String type;
  String contract;
  DateTime time;
}
