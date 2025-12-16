// lib/src/models/debate.dart

/// Argument type matching the contract's ArgumentType enum
enum ArgumentType { pro, con }

/// Model for a debate argument, matching the contract's ArgumentView struct
class DebateArgument {
  final BigInt id;
  final BigInt parentId;
  final ArgumentType argType;
  final String author;
  final String content;
  final BigInt directWeight;
  final BigInt netScore;
  final List<BigInt> proChildIds;
  final List<BigInt> conChildIds;
  final bool isValid;

  // References to child arguments (populated after parsing)
  List<DebateArgument> proChildren = [];
  List<DebateArgument> conChildren = [];
  DebateArgument? parent;

  DebateArgument({
    required this.id,
    required this.parentId,
    required this.argType,
    required this.author,
    required this.content,
    required this.directWeight,
    required this.netScore,
    required this.proChildIds,
    required this.conChildIds,
    required this.isValid,
  });

  factory DebateArgument.fromContractData(List<dynamic> data) {
    return DebateArgument(
      id: data[0] as BigInt,
      parentId: data[1] as BigInt,
      argType: (data[2] as BigInt).toInt() == 0 ? ArgumentType.pro : ArgumentType.con,
      author: data[3] as String,
      content: data[4] as String,
      directWeight: data[5] as BigInt,
      netScore: data[6] as BigInt,
      proChildIds: (data[7] as List).map((e) => e as BigInt).toList(),
      conChildIds: (data[8] as List).map((e) => e as BigInt).toList(),
      isValid: data[9] as bool,
    );
  }

  bool get isRoot => parentId == BigInt.zero;

  double get directWeightFormatted => directWeight.toDouble() / 1e18;
  double get netScoreFormatted => netScore.toDouble() / 1e18;
}

/// Model for a complete debate, matching the contract's DebateView struct
class Debate {
  final String debateAddress;
  final String title;
  final String token;
  final BigInt referenceBlock;
  final BigInt totalSupplyAtCreation;
  final BigInt totalStakedWeight;
  final BigInt argumentCount;
  final BigInt debateSentiment;
  final bool isOpen;
  final List<DebateArgument> arguments;

  // Computed from arguments
  DebateArgument? rootArgument;

  Debate({
    required this.debateAddress,
    required this.title,
    required this.token,
    required this.referenceBlock,
    required this.totalSupplyAtCreation,
    required this.totalStakedWeight,
    required this.argumentCount,
    required this.debateSentiment,
    required this.isOpen,
    required this.arguments,
  }) {
    _buildArgumentTree();
  }

  factory Debate.fromContractData(List<dynamic> data) {
    final argumentsData = data[9] as List;
    final arguments = argumentsData.map((a) => DebateArgument.fromContractData(a as List)).toList();

    return Debate(
      debateAddress: data[0] as String,
      title: data[1] as String,
      token: data[2] as String,
      referenceBlock: data[3] as BigInt,
      totalSupplyAtCreation: data[4] as BigInt,
      totalStakedWeight: data[5] as BigInt,
      argumentCount: data[6] as BigInt,
      debateSentiment: data[7] as BigInt,
      isOpen: data[8] as bool,
      arguments: arguments,
    );
  }

  void _buildArgumentTree() {
    // Create a map for quick lookup
    final argumentMap = <BigInt, DebateArgument>{};
    for (final arg in arguments) {
      argumentMap[arg.id] = arg;
    }

    // Link parents and children
    for (final arg in arguments) {
      if (arg.parentId == BigInt.zero) {
        rootArgument = arg;
      } else {
        final parent = argumentMap[arg.parentId];
        if (parent != null) {
          arg.parent = parent;
          if (arg.argType == ArgumentType.pro) {
            parent.proChildren.add(arg);
          } else {
            parent.conChildren.add(arg);
          }
        }
      }
    }
  }

  double get sentimentFormatted => debateSentiment.toDouble() / 1e18;
  double get totalStakedFormatted => totalStakedWeight.toDouble() / 1e18;
}

/// Lightweight model for debate list display, matching contract's DebateListItem
class DebateListItem {
  final String debateAddress;
  final String title;
  final String creator;
  final BigInt createdAt;
  final BigInt argumentCount;
  final BigInt sentiment;
  final bool isOpen;

  DebateListItem({
    required this.debateAddress,
    required this.title,
    required this.creator,
    required this.createdAt,
    required this.argumentCount,
    required this.sentiment,
    required this.isOpen,
  });

  factory DebateListItem.fromContractData(List<dynamic> data) {
    return DebateListItem(
      debateAddress: data[0] as String,
      title: data[1] as String,
      creator: data[2] as String,
      createdAt: data[3] as BigInt,
      argumentCount: data[4] as BigInt,
      sentiment: data[5] as BigInt,
      isOpen: data[6] as bool,
    );
  }

  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch((createdAt.toInt()) * 1000);

  double get sentimentFormatted => sentiment.toDouble() / 1e18;
}
