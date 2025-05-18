// lib/screens/creator/dao_config.dart
import 'package:Homebase/entities/org.dart';

import '../../entities/proposal.dart'; // Assuming Member is defined here
import 'creator_utils.dart'; // For DaoTokenDeploymentMechanism

class DaoConfig {
  String? daoType;
  String? daoName;
  String? daoDescription;

  DaoTokenDeploymentMechanism tokenDeploymentMechanism =
      DaoTokenDeploymentMechanism.deployNewStandardToken;

  // Original fields for "deploy new token" - RETAINED FOR EXISTING FUNCTIONALITY
  String? tokenSymbol;
  int? numberOfDecimals;
  bool nonTransferrable = true;

  // ADDED: New fields for "wrap existing token"
  String? underlyingTokenAddress;
  String? wrappedTokenName;
  String? wrappedTokenSymbol;

  String? totalSupply;
  Map<String, String> registry = {};
  int? proposalThreshold = 1;
  int quorumThreshold = 4;
  double supermajority = 75.0;
  Duration? votingDuration;
  Duration? votingDelay;
  Duration? executionDelay;
  List<Member> members = []; // Member type from proposal.dart
  DaoConfig();
}
// lib/screens/creator/dao_config.dart
