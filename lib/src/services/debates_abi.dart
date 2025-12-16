// lib/src/services/debates_abi.dart

/// ABI definitions for DebatesFactory and Debate contracts

class DebatesAbi {
  // ========== DebatesFactory ABI ==========

  /// Create a new debate
  /// function createDebate(address _token, string calldata _title, string calldata _rootArgument, uint256 _rootWeight) external returns (address)
  static const String createDebate = '''
  [{
    "inputs": [
      {"name": "_token", "type": "address"},
      {"name": "_title", "type": "string"},
      {"name": "_rootArgument", "type": "string"},
      {"name": "_rootWeight", "type": "uint256"}
    ],
    "name": "createDebate",
    "outputs": [{"name": "", "type": "address"}],
    "stateMutability": "nonpayable",
    "type": "function"
  }]
  ''';

  /// Get debates by token
  /// function getDebatesByToken(address _token) external view returns (address[] memory)
  static const String getDebatesByToken = '''
  [{
    "inputs": [{"name": "_token", "type": "address"}],
    "name": "getDebatesByToken",
    "outputs": [{"name": "", "type": "address[]"}],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  /// Get debate list by token (with summaries)
  /// function getDebateListByToken(address _token) external view returns (DebateListItem[] memory)
  static const String getDebateListByToken = '''
  [{
    "inputs": [{"name": "_token", "type": "address"}],
    "name": "getDebateListByToken",
    "outputs": [{
      "components": [
        {"name": "debateAddress", "type": "address"},
        {"name": "title", "type": "string"},
        {"name": "creator", "type": "address"},
        {"name": "createdAt", "type": "uint256"},
        {"name": "argumentCount", "type": "uint256"},
        {"name": "sentiment", "type": "int256"},
        {"name": "isOpen", "type": "bool"}
      ],
      "name": "",
      "type": "tuple[]"
    }],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  /// Get debate count by token
  /// function getDebateCountByToken(address _token) external view returns (uint256)
  static const String getDebateCountByToken = '''
  [{
    "inputs": [{"name": "_token", "type": "address"}],
    "name": "getDebateCountByToken",
    "outputs": [{"name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  // ========== Debate Contract ABI ==========

  /// Get full debate with all arguments
  /// function getFullDebate() external view returns (DebateView memory)
  static const String getFullDebate = '''
  [{
    "inputs": [],
    "name": "getFullDebate",
    "outputs": [{
      "components": [
        {"name": "debateAddress", "type": "address"},
        {"name": "title", "type": "string"},
        {"name": "token", "type": "address"},
        {"name": "referenceBlock", "type": "uint256"},
        {"name": "totalSupplyAtCreation", "type": "uint256"},
        {"name": "totalStakedWeight", "type": "uint256"},
        {"name": "argumentCount", "type": "uint256"},
        {"name": "debateSentiment", "type": "int256"},
        {"name": "isOpen", "type": "bool"},
        {
          "components": [
            {"name": "id", "type": "uint256"},
            {"name": "parentId", "type": "uint256"},
            {"name": "argType", "type": "uint8"},
            {"name": "author", "type": "address"},
            {"name": "content", "type": "string"},
            {"name": "directWeight", "type": "uint256"},
            {"name": "netScore", "type": "int256"},
            {"name": "proChildIds", "type": "uint256[]"},
            {"name": "conChildIds", "type": "uint256[]"},
            {"name": "isValid", "type": "bool"}
          ],
          "name": "arguments",
          "type": "tuple[]"
        }
      ],
      "name": "",
      "type": "tuple"
    }],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  /// Add an argument
  /// function addArgument(uint256 _parentId, ArgumentType _argType, uint256 _weight, string calldata _content) external returns (uint256)
  static const String addArgument = '''
  [{
    "inputs": [
      {"name": "_parentId", "type": "uint256"},
      {"name": "_argType", "type": "uint8"},
      {"name": "_weight", "type": "uint256"},
      {"name": "_content", "type": "string"}
    ],
    "name": "addArgument",
    "outputs": [{"name": "", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  }]
  ''';

  /// Add weight to existing argument
  /// function addWeight(uint256 _argumentId, uint256 _additionalWeight) external
  static const String addWeight = '''
  [{
    "inputs": [
      {"name": "_argumentId", "type": "uint256"},
      {"name": "_additionalWeight", "type": "uint256"}
    ],
    "name": "addWeight",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }]
  ''';

  /// Get remaining voting power
  /// function getRemainingVotingPower(address _account) external view returns (uint256)
  static const String getRemainingVotingPower = '''
  [{
    "inputs": [{"name": "_account", "type": "address"}],
    "name": "getRemainingVotingPower",
    "outputs": [{"name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  /// Get debate sentiment
  /// function getDebateSentiment() external view returns (int256)
  static const String getDebateSentiment = '''
  [{
    "inputs": [],
    "name": "getDebateSentiment",
    "outputs": [{"name": "", "type": "int256"}],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  /// Check if debate is open
  /// function isDebateOpen() external view returns (bool)
  static const String isDebateOpen = '''
  [{
    "inputs": [],
    "name": "isDebateOpen",
    "outputs": [{"name": "", "type": "bool"}],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';

  /// Get single argument
  /// function getArgument(uint256 _argumentId) external view returns (ArgumentView memory)
  static const String getArgument = '''
  [{
    "inputs": [{"name": "_argumentId", "type": "uint256"}],
    "name": "getArgument",
    "outputs": [{
      "components": [
        {"name": "id", "type": "uint256"},
        {"name": "parentId", "type": "uint256"},
        {"name": "argType", "type": "uint8"},
        {"name": "author", "type": "address"},
        {"name": "content", "type": "string"},
        {"name": "directWeight", "type": "uint256"},
        {"name": "netScore", "type": "int256"},
        {"name": "proChildIds", "type": "uint256[]"},
        {"name": "conChildIds", "type": "uint256[]"},
        {"name": "isValid", "type": "bool"}
      ],
      "name": "",
      "type": "tuple"
    }],
    "stateMutability": "view",
    "type": "function"
  }]
  ''';
}
