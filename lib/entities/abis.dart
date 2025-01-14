List<String> daoAbiString = [
  'function BALLOT_TYPEHASH ()',
  'function CLOCK_MODE ()',
  'function COUNTING_MODE ()',
  'function EXTENDED_BALLOT_TYPEHASH ()',
  'function cancel (address[], uint256[], bytes[], bytes32)',
  'function castVote (uint256, uint8)',
  'function castVoteBySig (uint256, uint8, address, bytes)',
  'function castVoteWithReason (uint256, uint8, string)',
  'function castVoteWithReasonAndParams (uint256, uint8, string, bytes)',
  'function castVoteWithReasonAndParamsBySig (uint256, uint8, address, string, bytes, bytes)',
  'function clock ()',
  'function eip712Domain ()',
  'function execute (address[], uint256[], bytes[], bytes32)',
  'function getVotes (address, uint256)',
  'function getVotesWithParams (address, uint256, bytes)',
  'function hasVoted (uint256, address)',
  'function hashProposal (address[], uint256[], bytes[], bytes32)',
  'function name ()',
  'function nonces (address)',
  'function onERC1155BatchReceived (address, address, uint256[], uint256[], bytes)',
  'function onERC1155Received (address, address, uint256, uint256, bytes)',
  'function onERC721Received (address, address, uint256, bytes)',
  'function proposalDeadline (uint256)',
  'function proposalEta (uint256)',
  'function proposalNeedsQueuing (uint256)',
  'function proposalProposer (uint256)',
  'function proposalSnapshot (uint256)',
  'function proposalThreshold ()',
  'function proposalVotes (uint256)',
  'function propose (address[], uint256[], bytes[], string) returns (uint)',
  'function queue (address[], uint256[], bytes[], bytes32)',
  'function quorum (uint256)',
  'function quorumDenominator ()',
  'function quorumNumerator (uint256)',
  'function quorumNumerator ()',
  'function relay (address, uint256, bytes)',
  'function setProposalThreshold (uint256)',
  'function setVotingDelay (uint48)',
  'function setVotingPeriod (uint32)',
  'function state (uint256) returns (uint8)',
  'function supportsInterface (bytes4)',
  'function timelock ()',
  'function token ()',
  'function updateQuorumNumerator (uint256)',
  'function updateTimelock (address)',
  'function version ()',
  'function votingDelay ()',
  'function votingPeriod ()'
];

List<String> tokenAbiString = [
  'function CLOCK_MODE ()',
  'function DOMAIN_SEPARATOR ()',
  'function allowance (address, address)',
  'function approve (address, uint256)',
  'function balanceOf (address)',
  'function checkpoints (address, uint32)',
  'function clock ()',
  'function decimals ()',
  'function delegate (address)',
  'function delegateBySig (address, uint256, uint256, uint8, bytes32, bytes32)',
  'function delegates (address)',
  'function eip712Domain ()',
  'function getPastTotalSupply (uint256)',
  'function getPastVotes (address, uint256)',
  'function getVotes (address)',
  'function mint (address, uint256)',
  'function name ()',
  'function nonces (address)',
  'function numCheckpoints (address)',
  'function permit (address, address, uint256, uint256, uint8, bytes32, bytes32)',
  'function symbol ()',
  'function totalSupply ()',
  'function transfer (address, uint256)',
  'function transferFrom (address, address, uint256)'
];

List<String> timelockAbiString = [
  'function CANCELLER_ROLE ()',
  'function DEFAULT_ADMIN_ROLE ()',
  'function EXECUTOR_ROLE ()',
  'function PROPOSER_ROLE ()',
  'function cancel (bytes32)',
  'function execute (address, uint256, bytes, bytes32, bytes32)',
  'function executeBatch (address[], uint256[], bytes[], bytes32, bytes32)',
  'function getMinDelay ()',
  'function getOperationState (bytes32)',
  'function getRoleAdmin (bytes32)',
  'function getTimestamp (bytes32)',
  'function grantRole (bytes32, address)',
  'function hasRole (bytes32, address)',
  'function hashOperation (address, uint256, bytes, bytes32, bytes32)',
  'function hashOperationBatch (address[], uint256[], bytes[], bytes32, bytes32)',
  'function isOperation (bytes32)',
  'function isOperationDone (bytes32)',
  'function isOperationPending (bytes32)',
  'function isOperationReady (bytes32)',
  'function onERC1155BatchReceived (address, address, uint256[], uint256[], bytes)',
  'function onERC1155Received (address, address, uint256, uint256, bytes)',
  'function onERC721Received (address, address, uint256, bytes)',
  'function renounceRole (bytes32, address)',
  'function revokeRole (bytes32, address)',
  'function schedule (address, uint256, bytes, bytes32, bytes32, uint256)',
  'function scheduleBatch (address[], uint256[], bytes[], bytes32, bytes32, uint256)',
  'function supportsInterface (bytes4)',
  'function updateDelay (uint256)'
];

List<String> wrapperAbiStringGlobal = [
  'function deployDAO (address, address, string, uint48, uint32)',
  'function deployDAOwithToken((string name, string symbol, string description, uint8 decimals, uint256 executionDelay, address[] initialMembers, uint256[] initialAmounts, string[] keys, string[] values) params)',
  'function deployedDAOs (uint256)',
  'function getNumberOfDAOs() returns (uint)'
];

List<String> simpleDAOabiString = [
  'function queueProposal(string proposalHash)',
  'function execute(address, uint256)',
  'function deposit() payable',
  'function createProposal(string description)',
  'function vote()',
  'function executeProposal(uint256 proposalIndex)',
  'function withdraw()',
  'function owner() view returns (address)',
  'function shares(address) view returns (uint256)',
  'function totalShares() view returns (uint256)',
  'function proposalCount() view returns (uint256)',
  'function proposals(uint256) view returns (string description, uint256 voteCount, bool executed)'
];

String nftApiGlobal = '''
[
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"internalType": "uint8",
				"name": "decimals_",
				"type": "uint8"
			},
			{
				"internalType": "address[]",
				"name": "initialMembers",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "initialAmounts",
				"type": "uint256[]"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "CheckpointUnorderedInsertion",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "ECDSAInvalidSignature",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "length",
				"type": "uint256"
			}
		],
		"name": "ECDSAInvalidSignatureLength",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "s",
				"type": "bytes32"
			}
		],
		"name": "ECDSAInvalidSignatureS",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "increasedSupply",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "cap",
				"type": "uint256"
			}
		],
		"name": "ERC20ExceededSafeSupply",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "allowance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientAllowance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "balance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientBalance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "approver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidApprover",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidReceiver",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSpender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "deadline",
				"type": "uint256"
			}
		],
		"name": "ERC2612ExpiredSignature",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "signer",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "ERC2612InvalidSigner",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			},
			{
				"internalType": "uint48",
				"name": "clock",
				"type": "uint48"
			}
		],
		"name": "ERC5805FutureLookup",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "ERC6372InconsistentClock",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "currentNonce",
				"type": "uint256"
			}
		],
		"name": "InvalidAccountNonce",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "InvalidShortString",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint8",
				"name": "bits",
				"type": "uint8"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "SafeCastOverflowedUintDowncast",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "str",
				"type": "string"
			}
		],
		"name": "StringTooLong",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "expiry",
				"type": "uint256"
			}
		],
		"name": "VotesExpiredSignature",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "delegator",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "fromDelegate",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "toDelegate",
				"type": "address"
			}
		],
		"name": "DelegateChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "delegate",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "previousVotes",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newVotes",
				"type": "uint256"
			}
		],
		"name": "DelegateVotesChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "EIP712DomainChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "CLOCK_MODE",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "DOMAIN_SEPARATOR",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "admin",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "burn",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint32",
				"name": "pos",
				"type": "uint32"
			}
		],
		"name": "checkpoints",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint48",
						"name": "_key",
						"type": "uint48"
					},
					{
						"internalType": "uint208",
						"name": "_value",
						"type": "uint208"
					}
				],
				"internalType": "struct Checkpoints.Checkpoint208",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "clock",
		"outputs": [
			{
				"internalType": "uint48",
				"name": "",
				"type": "uint48"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "delegatee",
				"type": "address"
			}
		],
		"name": "delegate",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "delegatee",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "nonce",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "expiry",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "v",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "r",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "s",
				"type": "bytes32"
			}
		],
		"name": "delegateBySig",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "delegates",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "eip712Domain",
		"outputs": [
			{
				"internalType": "bytes1",
				"name": "fields",
				"type": "bytes1"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "version",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "chainId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "verifyingContract",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			},
			{
				"internalType": "uint256[]",
				"name": "extensions",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			}
		],
		"name": "getPastTotalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			}
		],
		"name": "getPastVotes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "getVotes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "isTransferable",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "mint",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "nonces",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "numCheckpoints",
		"outputs": [
			{
				"internalType": "uint32",
				"name": "",
				"type": "uint32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "deadline",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "v",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "r",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "s",
				"type": "bytes32"
			}
		],
		"name": "permit",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newAdmin",
				"type": "address"
			}
		],
		"name": "setAdmin",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
''';

String wrapperAbiGlobal = '''
[
	{
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "symbol",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "description",
						"type": "string"
					},
					{
						"internalType": "uint8",
						"name": "decimals",
						"type": "uint8"
					},
					{
						"internalType": "uint256",
						"name": "executionDelay",
						"type": "uint256"
					},
					{
						"internalType": "address[]",
						"name": "initialMembers",
						"type": "address[]"
					},
					{
						"internalType": "uint256[]",
						"name": "initialAmounts",
						"type": "uint256[]"
					},
					{
						"internalType": "string[]",
						"name": "keys",
						"type": "string[]"
					},
					{
						"internalType": "string[]",
						"name": "values",
						"type": "string[]"
					}
				],
				"internalType": "struct WrapperContract.DaoParams",
				"name": "params",
				"type": "tuple"
			}
		],
		"name": "deployDAOwithToken",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_tokenFactory",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_timelockFactory",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_daoFactory",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "dao",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "token",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address[]",
				"name": "initialMembers",
				"type": "address[]"
			},
			{
				"indexed": false,
				"internalType": "uint256[]",
				"name": "initialAmounts",
				"type": "uint256[]"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "description",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "executionDelay",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "registry",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string[]",
				"name": "keys",
				"type": "string[]"
			},
			{
				"indexed": false,
				"internalType": "string[]",
				"name": "values",
				"type": "string[]"
			}
		],
		"name": "NewDaoCreated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "deployedDAOs",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "deployedRegistries",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "deployedTimelocks",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "deployedTokens",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getNumberOfDAOs",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
''';

String daoBytecodeGlobal =
    "610180604052348015610010575f80fd5b5060405161819f38038061819f83398181016040528101906100329190610c83565b806004836078610e1060016040518060400160405280600a81526020017f4d79476f7665726e6f7200000000000000000000000000000000000000000000815250806100826101c960201b60201c565b6100955f8361020660201b90919060201c565b61012081815250506100b160018261020660201b90919060201c565b6101408181525050818051906020012060e08181525050808051906020012061010081815250504660a081815250506100ee61025360201b60201c565b608081815250503073ffffffffffffffffffffffffffffffffffffffff1660c08173ffffffffffffffffffffffffffffffffffffffff16815250505050806003908161013a9190610efb565b505061014b836102ad60201b60201c565b61015a8261032060201b60201c565b610169816103d960201b60201c565b5050508073ffffffffffffffffffffffffffffffffffffffff166101608173ffffffffffffffffffffffffffffffffffffffff1681525050506101b18161041e60201b60201c565b506101c1816104f860201b60201c565b505050611459565b60606040518060400160405280600181526020017f3100000000000000000000000000000000000000000000000000000000000000815250905090565b5f602083511015610227576102208361059560201b60201c565b905061024d565b82610237836105fa60201b60201c565b5f0190816102459190610efb565b5060ff5f1b90505b92915050565b5f7f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f60e051610100514630604051602001610292959493929190611000565b60405160208183030381529060405280519060200120905090565b7fc565b045403dc03c2eea82b81a0465edad9e2e7fc4d97e11421c209da93d7a9360085f9054906101000a900465ffffffffffff16826040516102f1929190611092565b60405180910390a18060085f6101000a81548165ffffffffffff021916908365ffffffffffff16021790555050565b5f8163ffffffff160361036a575f6040517ff1cfbf0500000000000000000000000000000000000000000000000000000000815260040161036191906110f2565b60405180910390fd5b7f7e3f7f0708a84de9203036abaa450dccc85ad5ff52f78c170f3edb55cf5e8828600860069054906101000a900463ffffffff16826040516103ad92919061114a565b60405180910390a180600860066101000a81548163ffffffff021916908363ffffffff16021790555050565b7fccb45da8d5717e6c4544694297c4ba5cf151d455c9bb0ed4fc7a38411bc054616007548260405161040c929190611171565b60405180910390a18060078190555050565b5f61042d61060360201b60201c565b9050808211156104765781816040517f243e544500000000000000000000000000000000000000000000000000000000815260040161046d929190611171565b60405180910390fd5b5f61048561060b60201b60201c565b90506104b861049861063d60201b60201c565b6104a7856106d460201b60201c565b600a61074160201b9092919060201c565b50507f0553476bf02ef2726e8ce5ced78d63e26e602e4a2257b1f559418e24b463399781846040516104eb929190611171565b60405180910390a1505050565b7f08f74ea46ef7894f65eabfb5e6e695de773a000b47c529ab559178069b226401600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff168260405161054a929190611198565b60405180910390a180600b5f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b5f80829050601f815111156105e157826040517f305a27a90000000000000000000000000000000000000000000000000000000081526004016105d89190611225565b60405180910390fd5b8051816105ed90611272565b5f1c175f1b915050919050565b5f819050919050565b5f6064905090565b5f61061c600a61076260201b60201c565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16905090565b5f61064c6107ca60201b60201c565b73ffffffffffffffffffffffffffffffffffffffff166391ddadf46040518163ffffffff1660e01b8152600401602060405180830381865afa9250505080156106b357506040513d601f19601f820116820180604052508101906106b09190611302565b60015b6106cc576106c56107d460201b60201c565b90506106d1565b809150505b90565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff80168211156107395760d0826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401610730929190611372565b60405180910390fd5b819050919050565b5f80610756855f0185856107e960201b60201c565b91509150935093915050565b5f80825f018054905090505f81146107c057610792835f0160018361078791906113c6565b610b5d60201b60201c565b5f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff166107c2565b5f5b915050919050565b5f61016051905090565b5f6107e443610b6f60201b60201c565b905090565b5f805f858054905090505f811115610a75575f6108188760018461080d91906113c6565b610b5d60201b60201c565b6040518060400160405290815f82015f9054906101000a900465ffffffffffff1665ffffffffffff1665ffffffffffff1681526020015f820160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff168152505090508565ffffffffffff16815f015165ffffffffffff161115610903576040517f2520601d00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8565ffffffffffff16815f015165ffffffffffff160361098b578461093a8860018561092f91906113c6565b610b5d60201b60201c565b5f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff160217905550610a64565b8660405180604001604052808865ffffffffffff1681526020018779ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505b806020015185935093505050610b55565b8560405180604001604052808765ffffffffffff1681526020018679ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505f8492509250505b935093915050565b5f825f528160205f2001905092915050565b5f65ffffffffffff8016821115610bc0576030826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401610bb7929190611432565b60405180910390fd5b819050919050565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f610bf582610bcc565b9050919050565b5f610c0682610beb565b9050919050565b610c1681610bfc565b8114610c20575f80fd5b50565b5f81519050610c3181610c0d565b92915050565b5f610c4182610bcc565b9050919050565b5f610c5282610c37565b9050919050565b610c6281610c48565b8114610c6c575f80fd5b50565b5f81519050610c7d81610c59565b92915050565b5f8060408385031215610c9957610c98610bc8565b5b5f610ca685828601610c23565b9250506020610cb785828601610c6f565b9150509250929050565b5f81519050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602260045260245ffd5b5f6002820490506001821680610d3c57607f821691505b602082108103610d4f57610d4e610cf8565b5b50919050565b5f819050815f5260205f209050919050565b5f6020601f8301049050919050565b5f82821b905092915050565b5f60088302610db17fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff82610d76565b610dbb8683610d76565b95508019841693508086168417925050509392505050565b5f819050919050565b5f819050919050565b5f610dff610dfa610df584610dd3565b610ddc565b610dd3565b9050919050565b5f819050919050565b610e1883610de5565b610e2c610e2482610e06565b848454610d82565b825550505050565b5f90565b610e40610e34565b610e4b818484610e0f565b505050565b5b81811015610e6e57610e635f82610e38565b600181019050610e51565b5050565b601f821115610eb357610e8481610d55565b610e8d84610d67565b81016020851015610e9c578190505b610eb0610ea885610d67565b830182610e50565b50505b505050565b5f82821c905092915050565b5f610ed35f1984600802610eb8565b1980831691505092915050565b5f610eeb8383610ec4565b9150826002028217905092915050565b610f0482610cc1565b67ffffffffffffffff811115610f1d57610f1c610ccb565b5b610f278254610d25565b610f32828285610e72565b5f60209050601f831160018114610f63575f8415610f51578287015190505b610f5b8582610ee0565b865550610fc2565b601f198416610f7186610d55565b5f5b82811015610f9857848901518255600182019150602085019450602081019050610f73565b86831015610fb55784890151610fb1601f891682610ec4565b8355505b6001600288020188555050505b505050505050565b5f819050919050565b610fdc81610fca565b82525050565b610feb81610dd3565b82525050565b610ffa81610beb565b82525050565b5f60a0820190506110135f830188610fd3565b6110206020830187610fd3565b61102d6040830186610fd3565b61103a6060830185610fe2565b6110476080830184610ff1565b9695505050505050565b5f65ffffffffffff82169050919050565b5f61107c61107761107284611051565b610ddc565b610dd3565b9050919050565b61108c81611062565b82525050565b5f6040820190506110a55f830185611083565b6110b26020830184611083565b9392505050565b5f819050919050565b5f6110dc6110d76110d2846110b9565b610ddc565b610dd3565b9050919050565b6110ec816110c2565b82525050565b5f6020820190506111055f8301846110e3565b92915050565b5f63ffffffff82169050919050565b5f61113461112f61112a8461110b565b610ddc565b610dd3565b9050919050565b6111448161111a565b82525050565b5f60408201905061115d5f83018561113b565b61116a602083018461113b565b9392505050565b5f6040820190506111845f830185610fe2565b6111916020830184610fe2565b9392505050565b5f6040820190506111ab5f830185610ff1565b6111b86020830184610ff1565b9392505050565b5f82825260208201905092915050565b8281835e5f83830152505050565b5f601f19601f8301169050919050565b5f6111f782610cc1565b61120181856111bf565b93506112118185602086016111cf565b61121a816111dd565b840191505092915050565b5f6020820190508181035f83015261123d81846111ed565b905092915050565b5f81519050919050565b5f819050602082019050919050565b5f6112698251610fca565b80915050919050565b5f61127c82611245565b826112868461124f565b90506112918161125e565b925060208210156112d1576112cc7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff83602003600802610d76565b831692505b5050919050565b6112e181611051565b81146112eb575f80fd5b50565b5f815190506112fc816112d8565b92915050565b5f6020828403121561131757611316610bc8565b5b5f611324848285016112ee565b91505092915050565b5f819050919050565b5f60ff82169050919050565b5f61135c6113576113528461132d565b610ddc565b611336565b9050919050565b61136c81611342565b82525050565b5f6040820190506113855f830185611363565b6113926020830184610fe2565b9392505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f6113d082610dd3565b91506113db83610dd3565b92508282039050818111156113f3576113f2611399565b5b92915050565b5f819050919050565b5f61141c611417611412846113f9565b610ddc565b611336565b9050919050565b61142c81611402565b82525050565b5f6040820190506114455f830185611423565b6114526020830184610fe2565b9392505050565b60805160a05160c05160e05161010051610120516101405161016051616ceb6114b45f395f611edc01525f612df701525f612dbc01525f61455601525f61453501525f61388d01525f6138e301525f61390c0152616ceb5ff3fe608060405260043610610296575f3560e01c80637ecebe0011610159578063c01f9e37116100c0578063e540d01d11610079578063e540d01d14610b89578063eb9019d414610bb1578063ece40cc114610bed578063f23a6e6114610c15578063f8ce560a14610c51578063fc0c546a14610c8d57610309565b8063c01f9e3714610a77578063c28bc2fa14610ab3578063c59057e414610acf578063d33219b414610b0b578063dd4e2ba514610b35578063deaaa7cc14610b5f57610309565b8063a7713a7011610112578063a7713a7014610947578063a890c91014610971578063a9a9529414610999578063ab58fb8e146109d5578063b58131b014610a11578063bc197c8114610a3b57610309565b80637ecebe001461080f57806384b0196e1461084b5780638ff262e31461087b57806391ddadf4146108b757806397c3d334146108e15780639a802a6d1461090b57610309565b806343859632116101fd5780635b8d0e0d116101b65780635b8d0e0d146106bb5780635f398a14146106f757806360c4247f14610733578063790518871461076f5780637b3c71d3146107975780637d5e81e2146107d357610309565b80634385963214610575578063452115d6146105b15780634bf5d7e9146105ed578063544ffc9c1461061757806354fd4d5014610655578063567813881461067f57610309565b8063160cbed71161024f578063160cbed71461043d5780632656227d146104795780632d63f693146104a95780632fe3e261146104e55780633932abb11461050f5780633e4f49e61461053957610309565b806301ffc9a71461030d57806302a251a31461034957806306f3f9e61461037357806306fdde031461039b578063143489d0146103c5578063150b7a021461040157610309565b36610309573073ffffffffffffffffffffffffffffffffffffffff166102ba610cb7565b73ffffffffffffffffffffffffffffffffffffffff1614610307576040517fe90a651e00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b005b5f80fd5b348015610318575f80fd5b50610333600480360381019061032e91906148c7565b610cc5565b604051610340919061490c565b60405180910390f35b348015610354575f80fd5b5061035d610da6565b60405161036a919061493d565b60405180910390f35b34801561037e575f80fd5b5061039960048036038101906103949190614980565b610db4565b005b3480156103a6575f80fd5b506103af610dc8565b6040516103bc9190614a1b565b60405180910390f35b3480156103d0575f80fd5b506103eb60048036038101906103e69190614980565b610e58565b6040516103f89190614a7a565b60405180910390f35b34801561040c575f80fd5b5061042760048036038101906104229190614be9565b610e93565b6040516104349190614c78565b60405180910390f35b348015610448575f80fd5b50610463600480360381019061045e9190614f26565b610f12565b604051610470919061493d565b60405180910390f35b610493600480360381019061048e9190614f26565b611008565b6040516104a0919061493d565b60405180910390f35b3480156104b4575f80fd5b506104cf60048036038101906104ca9190614980565b6111e2565b6040516104dc919061493d565b60405180910390f35b3480156104f0575f80fd5b506104f9611218565b6040516105069190614fed565b60405180910390f35b34801561051a575f80fd5b5061052361123c565b604051610530919061493d565b60405180910390f35b348015610544575f80fd5b5061055f600480360381019061055a9190614980565b61124a565b60405161056c9190615079565b60405180910390f35b348015610580575f80fd5b5061059b60048036038101906105969190615092565b61125b565b6040516105a8919061490c565b60405180910390f35b3480156105bc575f80fd5b506105d760048036038101906105d29190614f26565b6112c0565b6040516105e4919061493d565b60405180910390f35b3480156105f8575f80fd5b50610601611380565b60405161060e9190614a1b565b60405180910390f35b348015610622575f80fd5b5061063d60048036038101906106389190614980565b61143d565b60405161064c939291906150d0565b60405180910390f35b348015610660575f80fd5b50610669611470565b6040516106769190614a1b565b60405180910390f35b34801561068a575f80fd5b506106a560048036038101906106a0919061513b565b6114ad565b6040516106b2919061493d565b60405180910390f35b3480156106c6575f80fd5b506106e160048036038101906106dc91906151d2565b6114dc565b6040516106ee919061493d565b60405180910390f35b348015610702575f80fd5b5061071d600480360381019061071891906152b4565b61160b565b60405161072a919061493d565b60405180910390f35b34801561073e575f80fd5b5061075960048036038101906107549190614980565b611673565b604051610766919061493d565b60405180910390f35b34801561077a575f80fd5b506107956004803603810190610790919061538f565b61176c565b005b3480156107a2575f80fd5b506107bd60048036038101906107b891906153ba565b611780565b6040516107ca919061493d565b60405180910390f35b3480156107de575f80fd5b506107f960048036038101906107f491906154c9565b6117e6565b604051610806919061493d565b60405180910390f35b34801561081a575f80fd5b506108356004803603810190610830919061559d565b6118d3565b604051610842919061493d565b60405180910390f35b348015610856575f80fd5b5061085f611919565b60405161087297969594939291906156b9565b60405180910390f35b348015610886575f80fd5b506108a1600480360381019061089c919061573b565b6119be565b6040516108ae919061493d565b60405180910390f35b3480156108c2575f80fd5b506108cb611a92565b6040516108d891906157ca565b60405180910390f35b3480156108ec575f80fd5b506108f5611b1d565b604051610902919061493d565b60405180910390f35b348015610916575f80fd5b50610931600480360381019061092c91906157e3565b611b25565b60405161093e919061493d565b60405180910390f35b348015610952575f80fd5b5061095b611b3a565b604051610968919061493d565b60405180910390f35b34801561097c575f80fd5b506109976004803603810190610992919061589b565b611b66565b005b3480156109a4575f80fd5b506109bf60048036038101906109ba9190614980565b611b7a565b6040516109cc919061490c565b60405180910390f35b3480156109e0575f80fd5b506109fb60048036038101906109f69190614980565b611b8b565b604051610a08919061493d565b60405180910390f35b348015610a1c575f80fd5b50610a25611bc1565b604051610a32919061493d565b60405180910390f35b348015610a46575f80fd5b50610a616004803603810190610a5c91906158c6565b611bcf565b604051610a6e9190614c78565b60405180910390f35b348015610a82575f80fd5b50610a9d6004803603810190610a989190614980565b611c4f565b604051610aaa919061493d565b60405180910390f35b610acd6004803603810190610ac891906159e6565b611cb9565b005b348015610ada575f80fd5b50610af56004803603810190610af09190614f26565b611d42565b604051610b02919061493d565b60405180910390f35b348015610b16575f80fd5b50610b1f611d7c565b604051610b2c9190614a7a565b60405180910390f35b348015610b40575f80fd5b50610b49611da4565b604051610b569190614a1b565b60405180910390f35b348015610b6a575f80fd5b50610b73611de1565b604051610b809190614fed565b60405180910390f35b348015610b94575f80fd5b50610baf6004803603810190610baa9190615a90565b611e05565b005b348015610bbc575f80fd5b50610bd76004803603810190610bd29190615abb565b611e19565b604051610be4919061493d565b60405180910390f35b348015610bf8575f80fd5b50610c136004803603810190610c0e9190614980565b611e34565b005b348015610c20575f80fd5b50610c3b6004803603810190610c369190615af9565b611e48565b604051610c489190614c78565b60405180910390f35b348015610c5c575f80fd5b50610c776004803603810190610c729190614980565b611ec8565b604051610c84919061493d565b60405180910390f35b348015610c98575f80fd5b50610ca1611ed9565b604051610cae9190615be7565b60405180910390f35b5f610cc0611f00565b905090565b5f7f65455a86000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19161480610d8f57507f4e2312e0000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916145b80610d9f5750610d9e82611f28565b5b9050919050565b5f610daf611f91565b905090565b610dbc611fb0565b610dc5816120a5565b50565b606060038054610dd790615c2d565b80601f0160208091040260200160405190810160405280929190818152602001828054610e0390615c2d565b8015610e4e5780601f10610e2557610100808354040283529160200191610e4e565b820191905f5260205f20905b815481529060010190602001808311610e3157829003601f168201915b5050505050905090565b5f60045f8381526020019081526020015f205f015f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b5f3073ffffffffffffffffffffffffffffffffffffffff16610eb3610cb7565b73ffffffffffffffffffffffffffffffffffffffff1614610f00576040517fe90a651e00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b63150b7a0260e01b9050949350505050565b5f80610f2086868686611d42565b9050610f3581610f306004612167565b61218b565b505f610f4482888888886121f6565b90505f8165ffffffffffff1614610fc9578060045f8481526020019081526020015f206001015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055507f9a2e42fd6722813d69113e7d0079d3d940171428df7373df9c7f7617cfda28928282604051610fbc929190615c8d565b60405180910390a1610ffb565b6040517f90884a4600000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8192505050949350505050565b5f8061101686868686611d42565b9050611036816110266005612167565b6110306004612167565b1761218b565b50600160045f8381526020019081526020015f205f01601e6101000a81548160ff0219169083151502179055503073ffffffffffffffffffffffffffffffffffffffff16611082610cb7565b73ffffffffffffffffffffffffffffffffffffffff1614611138575f5b8651811015611136573073ffffffffffffffffffffffffffffffffffffffff168782815181106110d2576110d1615cb4565b5b602002602001015173ffffffffffffffffffffffffffffffffffffffff160361112b5761112a85828151811061110b5761110a615cb4565b5b602002602001015180519060200120600561220f90919063ffffffff16565b5b80600101905061109f565b505b611145818787878761232e565b3073ffffffffffffffffffffffffffffffffffffffff16611164610cb7565b73ffffffffffffffffffffffffffffffffffffffff161415801561118f575061118d6005612342565b155b1561119f5761119e60056123ae565b5b7f712ae1383f79ac853f8d882153778e0260ef8f03b504e2866e0593e04d2b291f816040516111ce919061493d565b60405180910390a180915050949350505050565b5f60045f8381526020019081526020015f205f0160149054906101000a900465ffffffffffff1665ffffffffffff169050919050565b7f3e83946653575f9a39005e1545185629e92736b7528ab20ca3816f315424a81181565b5f611245612424565b905090565b5f61125482612446565b9050919050565b5f60095f8481526020019081526020015f206003015f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900460ff16905092915050565b5f806112ce86868686611d42565b90506112e2816112dd5f612167565b61218b565b506112ec81610e58565b73ffffffffffffffffffffffffffffffffffffffff1661130a6125fb565b73ffffffffffffffffffffffffffffffffffffffff16146113695761132d6125fb565b6040517f233d98e30000000000000000000000000000000000000000000000000000000081526004016113609190614a7a565b60405180910390fd5b61137586868686612602565b915050949350505050565b606061138a611ed9565b73ffffffffffffffffffffffffffffffffffffffff16634bf5d7e96040518163ffffffff1660e01b81526004015f60405180830381865afa9250505080156113f457506040513d5f823e3d601f19601f820116820180604052508101906113f19190615d4f565b60015b611435576040518060400160405280601d81526020017f6d6f64653d626c6f636b6e756d6265722666726f6d3d64656661756c74000000815250905061143a565b809150505b90565b5f805f8060095f8681526020019081526020015f209050805f015481600101548260020154935093509350509193909250565b60606040518060400160405280600181526020017f3100000000000000000000000000000000000000000000000000000000000000815250905090565b5f806114b76125fb565b90506114d384828560405180602001604052805f815250612619565b91505092915050565b5f80611569876115637f3e83946653575f9a39005e1545185629e92736b7528ab20ca3816f315424a8118c8c8c6115128e612638565b8d8d604051611522929190615dc4565b60405180910390208c805190602001206040516020016115489796959493929190615deb565b6040516020818303038152906040528051906020012061268b565b856126a4565b9050806115ad57866040517f94ab6c070000000000000000000000000000000000000000000000000000000081526004016115a49190614a7a565b60405180910390fd5b6115fd89888a89898080601f0160208091040260200160405190810160405280939291908181526020018383808284375f81840152601f19601f8201169050808301925050505050505088612731565b915050979650505050505050565b5f806116156125fb565b905061166787828888888080601f0160208091040260200160405190810160405280939291908181526020018383808284375f81840152601f19601f8201169050808301925050505050505087612731565b91505095945050505050565b5f80600a5f018054905090505f600a5f016001836116919190615e85565b815481106116a2576116a1615cb4565b5b905f5260205f200190505f815f015f9054906101000a900465ffffffffffff1690505f825f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff169050858265ffffffffffff1611611728578079ffffffffffffffffffffffffffffffffffffffffffffffffffff16945050505050611767565b6117446117348761282e565b600a61288790919063ffffffff16565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff169450505050505b919050565b611774611fb0565b61177d81612974565b50565b5f8061178a6125fb565b90506117db86828787878080601f0160208091040260200160405190810160405280939291908181526020018383808284375f81840152601f19601f82011690508083019250505050505050612619565b915050949350505050565b5f806117f06125fb565b90506117fc81846129e7565b61183d57806040517fd9b395570000000000000000000000000000000000000000000000000000000081526004016118349190614a7a565b60405180910390fd5b5f61186382600161184c611a92565b6118569190615eb8565b65ffffffffffff16611e19565b90505f61186e611bc1565b9050808210156118b9578282826040517fc242ee160000000000000000000000000000000000000000000000000000000081526004016118b093929190615ef1565b60405180910390fd5b6118c68888888887612b2f565b9350505050949350505050565b5f60025f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050919050565b5f6060805f805f606061192a612db4565b611932612dee565b46305f801b5f67ffffffffffffffff81111561195157611950614ac5565b5b60405190808252806020026020018201604052801561197f5781602001602082028036833780820191505090505b507f0f00000000000000000000000000000000000000000000000000000000000000959493929190965096509650965096509650965090919293949596565b5f80611a2984611a237ff2aad550cf55f045cb27e9c559f9889fdfb6e6cdaa032301d6ea397784ae51d78989896119f48b612638565b604051602001611a08959493929190615f26565b6040516020818303038152906040528051906020012061268b565b856126a4565b905080611a6d57836040517f94ab6c07000000000000000000000000000000000000000000000000000000008152600401611a649190614a7a565b60405180910390fd5b611a8786858760405180602001604052805f815250612619565b915050949350505050565b5f611a9b611ed9565b73ffffffffffffffffffffffffffffffffffffffff166391ddadf46040518163ffffffff1660e01b8152600401602060405180830381865afa925050508015611b0257506040513d601f19601f82011682018060405250810190611aff9190615f8b565b60015b611b1557611b0e612e29565b9050611b1a565b809150505b90565b5f6064905090565b5f611b31848484612e38565b90509392505050565b5f611b45600a612ec3565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16905090565b611b6e611fb0565b611b7781612f25565b50565b5f611b8482612fc2565b9050919050565b5f60045f8381526020019081526020015f206001015f9054906101000a900465ffffffffffff1665ffffffffffff169050919050565b5f611bca612fcc565b905090565b5f3073ffffffffffffffffffffffffffffffffffffffff16611bef610cb7565b73ffffffffffffffffffffffffffffffffffffffff1614611c3c576040517fe90a651e00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b63bc197c8160e01b905095945050505050565b5f60045f8381526020019081526020015f205f01601a9054906101000a900463ffffffff1663ffffffff1660045f8481526020019081526020015f205f0160149054906101000a900465ffffffffffff16611caa9190615fb6565b65ffffffffffff169050919050565b611cc1611fb0565b5f808573ffffffffffffffffffffffffffffffffffffffff16858585604051611ceb929190615dc4565b5f6040518083038185875af1925050503d805f8114611d25576040519150601f19603f3d011682016040523d82523d5f602084013e611d2a565b606091505b5091509150611d398282612fd5565b50505050505050565b5f84848484604051602001611d5a94939291906161b3565b604051602081830303815290604052805190602001205f1c9050949350505050565b5f600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b60606040518060400160405280602081526020017f737570706f72743d627261766f2671756f72756d3d666f722c6162737461696e815250905090565b7ff2aad550cf55f045cb27e9c559f9889fdfb6e6cdaa032301d6ea397784ae51d781565b611e0d611fb0565b611e1681612ff9565b50565b5f611e2c8383611e276130b2565b612e38565b905092915050565b611e3c611fb0565b611e45816130c8565b50565b5f3073ffffffffffffffffffffffffffffffffffffffff16611e68610cb7565b73ffffffffffffffffffffffffffffffffffffffff1614611eb5576040517fe90a651e00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b63f23a6e6160e01b905095945050505050565b5f611ed28261310d565b9050919050565b5f7f0000000000000000000000000000000000000000000000000000000000000000905090565b5f600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b5f7f01ffc9a7000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916149050919050565b5f600860069054906101000a900463ffffffff1663ffffffff16905090565b611fb86125fb565b73ffffffffffffffffffffffffffffffffffffffff16611fd6610cb7565b73ffffffffffffffffffffffffffffffffffffffff161461203557611ff96125fb565b6040517f47096e4700000000000000000000000000000000000000000000000000000000815260040161202c9190614a7a565b60405180910390fd5b3073ffffffffffffffffffffffffffffffffffffffff16612054610cb7565b73ffffffffffffffffffffffffffffffffffffffff16146120a3575f6120786131b9565b604051612086929190615dc4565b604051809103902090505b8061209c60056131c5565b0361209157505b565b5f6120ae611b1d565b9050808211156120f75781816040517f243e54450000000000000000000000000000000000000000000000000000000081526004016120ee92919061620b565b60405180910390fd5b5f612100611b3a565b905061212761210d611a92565b6121168561331a565b600a6133879092919063ffffffff16565b50507f0553476bf02ef2726e8ce5ced78d63e26e602e4a2257b1f559418e24b4633997818460405161215a92919061620b565b60405180910390a1505050565b5f81600781111561217b5761217a615006565b5b60ff166001901b5f1b9050919050565b5f806121968461124a565b90505f801b836121a583612167565b16036121ec578381846040517f31b75e4d0000000000000000000000000000000000000000000000000000000081526004016121e393929190616232565b60405180910390fd5b8091505092915050565b5f61220486868686866133a2565b905095945050505050565b5f825f0160109054906101000a90046fffffffffffffffffffffffffffffffff169050825f015f9054906101000a90046fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff16600182016fffffffffffffffffffffffffffffffff16036122b0576040517f8acb5f2700000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b81836001015f836fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff1681526020019081526020015f208190555060018101835f0160106101000a8154816fffffffffffffffffffffffffffffffff02191690836fffffffffffffffffffffffffffffffff160217905550505050565b61233b85858585856135a8565b5050505050565b5f815f015f9054906101000a90046fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff16825f0160109054906101000a90046fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff16149050919050565b5f815f015f6101000a8154816fffffffffffffffffffffffffffffffff02191690836fffffffffffffffffffffffffffffffff1602179055505f815f0160106101000a8154816fffffffffffffffffffffffffffffffff02191690836fffffffffffffffffffffffffffffffff16021790555050565b5f60085f9054906101000a900465ffffffffffff1665ffffffffffff16905090565b5f806124518361365c565b90506005600781111561246757612466615006565b5b81600781111561247a57612479615006565b5b1461248857809150506125f6565b5f600c5f8581526020019081526020015f20549050600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663584b153e826040518263ffffffff1660e01b81526004016124f79190614fed565b602060405180830381865afa158015612512573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906125369190616291565b15612546576005925050506125f6565b600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16632ab0f529826040518263ffffffff1660e01b81526004016125a09190614fed565b602060405180830381865afa1580156125bb573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906125df9190616291565b156125ef576007925050506125f6565b6002925050505b919050565b5f33905090565b5f61260f858585856137b3565b9050949350505050565b5f61262e858585856126296130b2565b612731565b9050949350505050565b5f60025f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f815480929190600101919050559050919050565b5f61269d61269761388a565b83613940565b9050919050565b5f805f6126b18585613980565b50915091505f60038111156126c9576126c8615006565b5b8160038111156126dc576126db615006565b5b14801561271457508573ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16145b8061272657506127258686866139d5565b5b925050509392505050565b5f612745866127406001612167565b61218b565b505f61275a86612754896111e2565b85612e38565b90506127698787878487613af4565b5f8351036127ca578573ffffffffffffffffffffffffffffffffffffffff167fb8e138887d0aa13bab447e82de9d5c1777041ecd21ca36ba824ff1e6c07ddda4888784886040516127bd94939291906162bc565b60405180910390a2612821565b8573ffffffffffffffffffffffffffffffffffffffff167fe2babfbac5889a709b63bb7f598b324e08bc5a4fb9ec647fb3cbc9ec07eb8712888784888860405161281895949392919061634e565b60405180910390a25b8091505095945050505050565b5f65ffffffffffff801682111561287f576030826040517f6dfcc6500000000000000000000000000000000000000000000000000000000081526004016128769291906163e6565b60405180910390fd5b819050919050565b5f80835f018054905090505f808290506005831115612908575f6128aa84613ce3565b846128b59190615e85565b90506128c3875f0182613dd9565b5f015f9054906101000a900465ffffffffffff1665ffffffffffff168665ffffffffffff1610156128f657809150612906565b600181612903919061640d565b92505b505b5f612917875f01878585613deb565b90505f811461296657612938875f016001836129339190615e85565b613dd9565b5f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff16612968565b5f5b94505050505092915050565b7fc565b045403dc03c2eea82b81a0465edad9e2e7fc4d97e11421c209da93d7a9360085f9054906101000a900465ffffffffffff16826040516129b8929190616440565b60405180910390a18060085f6101000a81548165ffffffffffff021916908365ffffffffffff16021790555050565b5f80825190506034811015612a00576001915050612b29565b5f6014820384015190507f2370726f706f7365723d3078000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff19168173ffffffffffffffffffffffffffffffffffffffff191614612a6a57600192505050612b29565b5f80602884612a799190615e85565b90505b83811015612af3575f80612aac888481518110612a9c57612a9b615cb4565b5b602001015160f81c60f81b613e60565b9150915081612ac45760019650505050505050612b29565b8060ff1660048573ffffffffffffffffffffffffffffffffffffffff16901b1793505050806001019050612a7c565b508573ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161493505050505b92915050565b5f612b438686868680519060200120611d42565b905084518651141580612b5857508351865114155b80612b6357505f8651145b15612bac578551845186516040517f447b05d0000000000000000000000000000000000000000000000000000000008152600401612ba3939291906150d0565b60405180910390fd5b5f60045f8381526020019081526020015f205f0160149054906101000a900465ffffffffffff1665ffffffffffff1614612c2b5780612bea8261124a565b5f801b6040517f31b75e4d000000000000000000000000000000000000000000000000000000008152600401612c2293929190616232565b60405180910390fd5b5f612c3461123c565b612c3c611a92565b65ffffffffffff16612c4e919061640d565b90505f612c59610da6565b90505f60045f8581526020019081526020015f20905084815f015f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550612cb98361282e565b815f0160146101000a81548165ffffffffffff021916908365ffffffffffff160217905550612ce782613ef7565b815f01601a6101000a81548163ffffffff021916908363ffffffff1602179055507f7d84a6263ae0d98d3329bd7b46bb4e8d6f98cd35a7adb45c274c8b7fd5ebd5e084868b8b8d5167ffffffffffffffff811115612d4857612d47614ac5565b5b604051908082528060200260200182016040528015612d7b57816020015b6060815260200190600190039081612d665790505b508c89898b612d8a919061640d565b8e604051612da09998979695949392919061656a565b60405180910390a150505095945050505050565b6060612de95f7f0000000000000000000000000000000000000000000000000000000000000000613f4e90919063ffffffff16565b905090565b6060612e2460017f0000000000000000000000000000000000000000000000000000000000000000613f4e90919063ffffffff16565b905090565b5f612e334361282e565b905090565b5f612e41611ed9565b73ffffffffffffffffffffffffffffffffffffffff16633a46b1a885856040518363ffffffff1660e01b8152600401612e7b929190616618565b602060405180830381865afa158015612e96573d5f803e3d5ffd5b505050506040513d601f19601f82011682018060405250810190612eba9190616653565b90509392505050565b5f80825f018054905090505f8114612f1b57612eed835f01600183612ee89190615e85565b613dd9565b5f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff16612f1d565b5f5b915050919050565b7f08f74ea46ef7894f65eabfb5e6e695de773a000b47c529ab559178069b226401600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1682604051612f7792919061667e565b60405180910390a180600b5f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b5f60019050919050565b5f600754905090565b606082612fea57612fe582613ffb565b612ff2565b819050612ff3565b5b92915050565b5f8163ffffffff1603613043575f6040517ff1cfbf0500000000000000000000000000000000000000000000000000000000815260040161303a91906166de565b60405180910390fd5b7f7e3f7f0708a84de9203036abaa450dccc85ad5ff52f78c170f3edb55cf5e8828600860069054906101000a900463ffffffff1682604051613086929190616727565b60405180910390a180600860066101000a81548163ffffffff021916908363ffffffff16021790555050565b606060405180602001604052805f815250905090565b7fccb45da8d5717e6c4544694297c4ba5cf151d455c9bb0ed4fc7a38411bc05461600754826040516130fb92919061620b565b60405180910390a18060078190555050565b5f613116611b1d565b61311f83611673565b613127611ed9565b73ffffffffffffffffffffffffffffffffffffffff16638e539e8c856040518263ffffffff1660e01b815260040161315f919061493d565b602060405180830381865afa15801561317a573d5f803e3d5ffd5b505050506040513d601f19601f8201168201806040525081019061319e9190616653565b6131a8919061674e565b6131b291906167bc565b9050919050565b365f8036915091509091565b5f80825f015f9054906101000a90046fffffffffffffffffffffffffffffffff169050825f0160109054906101000a90046fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff16816fffffffffffffffffffffffffffffffff1603613264576040517f75e52f4f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b826001015f826fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff1681526020019081526020015f20549150826001015f826fffffffffffffffffffffffffffffffff166fffffffffffffffffffffffffffffffff1681526020019081526020015f205f905560018101835f015f6101000a8154816fffffffffffffffffffffffffffffffff02191690836fffffffffffffffffffffffffffffffff16021790555050919050565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff801682111561337f5760d0826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401613376929190616825565b60405180910390fd5b819050919050565b5f80613396855f01858561403f565b91509150935093915050565b5f80600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663f27a0c926040518163ffffffff1660e01b8152600401602060405180830381865afa15801561340e573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906134329190616653565b90505f61343e846143a7565b9050600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663b1c5f4278888885f866040518663ffffffff1660e01b81526004016134a2959493929190616887565b602060405180830381865afa1580156134bd573d5f803e3d5ffd5b505050506040513d601f19601f820116820180604052508101906134e19190616901565b600c5f8a81526020019081526020015f2081905550600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16638f2a0bb08888885f86886040518763ffffffff1660e01b815260040161355a9695949392919061692c565b5f604051808303815f87803b158015613571575f80fd5b505af1158015613583573d5f803e3d5ffd5b5050505061359b8242613596919061640d565b61282e565b9250505095945050505050565b600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663e38335e5348686865f6135f3886143a7565b6040518763ffffffff1660e01b8152600401613613959493929190616887565b5f604051808303818588803b15801561362a575f80fd5b505af115801561363c573d5f803e3d5ffd5b5050505050600c5f8681526020019081526020015f205f90555050505050565b5f8060045f8481526020019081526020015f2090505f815f01601e9054906101000a900460ff1690505f825f01601f9054906101000a900460ff16905081156136ab57600793505050506137ae565b80156136bd57600293505050506137ae565b5f6136c7866111e2565b90505f810361370d57856040517f6ad06075000000000000000000000000000000000000000000000000000000008152600401613704919061493d565b60405180910390fd5b5f613716611a92565b65ffffffffffff169050808210613734575f955050505050506137ae565b5f61373e88611c4f565b905081811061375657600196505050505050506137ae565b61375f886143c4565b1580613771575061376f88614408565b155b1561378557600396505050505050506137ae565b5f61378f89611b8b565b036137a357600496505050505050506137ae565b600596505050505050505b919050565b5f806137c18686868661442f565b90505f600c5f8381526020019081526020015f205490505f801b811461387d57600b5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663c4d252f5826040518263ffffffff1660e01b815260040161383b9190614fed565b5f604051808303815f87803b158015613852575f80fd5b505af1158015613864573d5f803e3d5ffd5b50505050600c5f8381526020019081526020015f205f90555b8192505050949350505050565b5f7f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff163073ffffffffffffffffffffffffffffffffffffffff1614801561390557507f000000000000000000000000000000000000000000000000000000000000000046145b15613932577f0000000000000000000000000000000000000000000000000000000000000000905061393d565b61393a614511565b90505b90565b5f6040517f190100000000000000000000000000000000000000000000000000000000000081528360028201528260228201526042812091505092915050565b5f805f60418451036139c0575f805f602087015192506040870151915060608701515f1a90506139b2888285856145a6565b9550955095505050506139ce565b5f600285515f1b9250925092505b9250925092565b5f805f8573ffffffffffffffffffffffffffffffffffffffff168585604051602401613a029291906169a0565b604051602081830303815290604052631626ba7e60e01b6020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff8381831617835250505050604051613a5491906169fe565b5f60405180830381855afa9150503d805f8114613a8c576040519150601f19603f3d011682016040523d82523d5f602084013e613a91565b606091505b5091509150818015613aa557506020815110155b8015613ae95750631626ba7e60e01b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff191681806020019051810190613ae79190616901565b145b925050509392505050565b5f60095f8781526020019081526020015f209050806003015f8673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900460ff1615613b9657846040517f71c6af49000000000000000000000000000000000000000000000000000000008152600401613b8d9190614a7a565b60405180910390fd5b6001816003015f8773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f6101000a81548160ff0219169083151502179055505f6002811115613c0057613bff615006565b5b60ff168460ff1603613c2a5782815f015f828254613c1e919061640d565b92505081905550613cdb565b60016002811115613c3e57613c3d615006565b5b60ff168460ff1603613c695782816001015f828254613c5d919061640d565b92505081905550613cda565b600280811115613c7c57613c7b615006565b5b60ff168460ff1603613ca75782816002015f828254613c9b919061640d565b92505081905550613cd9565b6040517f06b337c200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5b5b505050505050565b5f808203613cf3575f9050613dd4565b5f6001613cff8461468d565b901c6001901b90506001818481613d1957613d1861678f565b5b048201901c90506001818481613d3257613d3161678f565b5b048201901c90506001818481613d4b57613d4a61678f565b5b048201901c90506001818481613d6457613d6361678f565b5b048201901c90506001818481613d7d57613d7c61678f565b5b048201901c90506001818481613d9657613d9561678f565b5b048201901c90506001818481613daf57613dae61678f565b5b048201901c9050613dd081828581613dca57613dc961678f565b5b04614764565b9150505b919050565b5f825f528160205f2001905092915050565b5f5b81831015613e55575f613e00848461477c565b90508465ffffffffffff16613e158783613dd9565b5f015f9054906101000a900465ffffffffffff1665ffffffffffff161115613e3f57809250613e4f565b600181613e4c919061640d565b93505b50613ded565b819050949350505050565b5f805f8360f81c90508060ff16602f108015613e7f5750603a8160ff16105b15613e94576001603082039250925050613ef2565b8060ff166040108015613eaa575060478160ff16105b15613ebf576001603782039250925050613ef2565b8060ff166060108015613ed5575060678160ff16105b15613eea576001605782039250925050613ef2565b5f8092509250505b915091565b5f63ffffffff8016821115613f46576020826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401613f3d929190616a4d565b60405180910390fd5b819050919050565b606060ff5f1b8314613f6a57613f63836147a1565b9050613ff5565b818054613f7690615c2d565b80601f0160208091040260200160405190810160405280929190818152602001828054613fa290615c2d565b8015613fed5780601f10613fc457610100808354040283529160200191613fed565b820191905f5260205f20905b815481529060010190602001808311613fd057829003601f168201915b505050505090505b92915050565b5f8151111561400d5780518082602001fd5b6040517f1425ea4200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5f805f858054905090505f8111156142bf575f614068876001846140639190615e85565b613dd9565b6040518060400160405290815f82015f9054906101000a900465ffffffffffff1665ffffffffffff1665ffffffffffff1681526020015f820160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff168152505090508565ffffffffffff16815f015165ffffffffffff161115614153576040517f2520601d00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8565ffffffffffff16815f015165ffffffffffff16036141d557846141848860018561417f9190615e85565b613dd9565b5f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff1602179055506142ae565b8660405180604001604052808865ffffffffffff1681526020018779ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505b80602001518593509350505061439f565b8560405180604001604052808765ffffffffffff1681526020018679ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505f8492509250505b935093915050565b5f813060601b6bffffffffffffffffffffffff1916189050919050565b5f8060095f8481526020019081526020015f209050806002015481600101546143ed919061640d565b6143fe6143f9856111e2565b611ec8565b1115915050919050565b5f8060095f8481526020019081526020015f209050805f0154816001015411915050919050565b5f8061443d86868686611d42565b90506144a18161444d6007612167565b6144576006612167565b6144616002612167565b60018060078081111561447757614476615006565b5b6144819190616a74565b600261448d9190616bd7565b6144979190615e85565b5f1b18181861218b565b50600160045f8381526020019081526020015f205f01601f6101000a81548160ff0219169083151502179055507f789cf55be980739dad1d0699b93b58e806b51c9d96619bfa8fe0a28abaa7b30c816040516144fd919061493d565b60405180910390a180915050949350505050565b5f7f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f7f00000000000000000000000000000000000000000000000000000000000000007f0000000000000000000000000000000000000000000000000000000000000000463060405160200161458b959493929190616c21565b60405160208183030381529060405280519060200120905090565b5f805f7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0845f1c11156145e2575f600385925092509250614683565b5f6001888888886040515f81526020016040526040516146059493929190616c72565b6020604051602081039080840390855afa158015614625573d5f803e3d5ffd5b5050506020604051035190505f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1603614676575f60015f801b93509350935050614683565b805f805f1b935093509350505b9450945094915050565b5f805f90505f608084901c11156146ac57608083901c92506080810190505b5f604084901c11156146c657604083901c92506040810190505b5f602084901c11156146e057602083901c92506020810190505b5f601084901c11156146fa57601083901c92506010810190505b5f600884901c111561471457600883901c92506008810190505b5f600484901c111561472e57600483901c92506004810190505b5f600284901c111561474857600283901c92506002810190505b5f600184901c111561475b576001810190505b80915050919050565b5f8183106147725781614774565b825b905092915050565b5f600282841861478c91906167bc565b828416614799919061640d565b905092915050565b60605f6147ad83614813565b90505f602067ffffffffffffffff8111156147cb576147ca614ac5565b5b6040519080825280601f01601f1916602001820160405280156147fd5781602001600182028036833780820191505090505b5090508181528360208201528092505050919050565b5f8060ff835f1c169050601f811115614858576040517fb3512b0c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b80915050919050565b5f604051905090565b5f80fd5b5f80fd5b5f7fffffffff0000000000000000000000000000000000000000000000000000000082169050919050565b6148a681614872565b81146148b0575f80fd5b50565b5f813590506148c18161489d565b92915050565b5f602082840312156148dc576148db61486a565b5b5f6148e9848285016148b3565b91505092915050565b5f8115159050919050565b614906816148f2565b82525050565b5f60208201905061491f5f8301846148fd565b92915050565b5f819050919050565b61493781614925565b82525050565b5f6020820190506149505f83018461492e565b92915050565b61495f81614925565b8114614969575f80fd5b50565b5f8135905061497a81614956565b92915050565b5f602082840312156149955761499461486a565b5b5f6149a28482850161496c565b91505092915050565b5f81519050919050565b5f82825260208201905092915050565b8281835e5f83830152505050565b5f601f19601f8301169050919050565b5f6149ed826149ab565b6149f781856149b5565b9350614a078185602086016149c5565b614a10816149d3565b840191505092915050565b5f6020820190508181035f830152614a3381846149e3565b905092915050565b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f614a6482614a3b565b9050919050565b614a7481614a5a565b82525050565b5f602082019050614a8d5f830184614a6b565b92915050565b614a9c81614a5a565b8114614aa6575f80fd5b50565b5f81359050614ab781614a93565b92915050565b5f80fd5b5f80fd5b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b614afb826149d3565b810181811067ffffffffffffffff82111715614b1a57614b19614ac5565b5b80604052505050565b5f614b2c614861565b9050614b388282614af2565b919050565b5f67ffffffffffffffff821115614b5757614b56614ac5565b5b614b60826149d3565b9050602081019050919050565b828183375f83830152505050565b5f614b8d614b8884614b3d565b614b23565b905082815260208101848484011115614ba957614ba8614ac1565b5b614bb4848285614b6d565b509392505050565b5f82601f830112614bd057614bcf614abd565b5b8135614be0848260208601614b7b565b91505092915050565b5f805f8060808587031215614c0157614c0061486a565b5b5f614c0e87828801614aa9565b9450506020614c1f87828801614aa9565b9350506040614c308782880161496c565b925050606085013567ffffffffffffffff811115614c5157614c5061486e565b5b614c5d87828801614bbc565b91505092959194509250565b614c7281614872565b82525050565b5f602082019050614c8b5f830184614c69565b92915050565b5f67ffffffffffffffff821115614cab57614caa614ac5565b5b602082029050602081019050919050565b5f80fd5b5f614cd2614ccd84614c91565b614b23565b90508083825260208201905060208402830185811115614cf557614cf4614cbc565b5b835b81811015614d1e5780614d0a8882614aa9565b845260208401935050602081019050614cf7565b5050509392505050565b5f82601f830112614d3c57614d3b614abd565b5b8135614d4c848260208601614cc0565b91505092915050565b5f67ffffffffffffffff821115614d6f57614d6e614ac5565b5b602082029050602081019050919050565b5f614d92614d8d84614d55565b614b23565b90508083825260208201905060208402830185811115614db557614db4614cbc565b5b835b81811015614dde5780614dca888261496c565b845260208401935050602081019050614db7565b5050509392505050565b5f82601f830112614dfc57614dfb614abd565b5b8135614e0c848260208601614d80565b91505092915050565b5f67ffffffffffffffff821115614e2f57614e2e614ac5565b5b602082029050602081019050919050565b5f614e52614e4d84614e15565b614b23565b90508083825260208201905060208402830185811115614e7557614e74614cbc565b5b835b81811015614ebc57803567ffffffffffffffff811115614e9a57614e99614abd565b5b808601614ea78982614bbc565b85526020850194505050602081019050614e77565b5050509392505050565b5f82601f830112614eda57614ed9614abd565b5b8135614eea848260208601614e40565b91505092915050565b5f819050919050565b614f0581614ef3565b8114614f0f575f80fd5b50565b5f81359050614f2081614efc565b92915050565b5f805f8060808587031215614f3e57614f3d61486a565b5b5f85013567ffffffffffffffff811115614f5b57614f5a61486e565b5b614f6787828801614d28565b945050602085013567ffffffffffffffff811115614f8857614f8761486e565b5b614f9487828801614de8565b935050604085013567ffffffffffffffff811115614fb557614fb461486e565b5b614fc187828801614ec6565b9250506060614fd287828801614f12565b91505092959194509250565b614fe781614ef3565b82525050565b5f6020820190506150005f830184614fde565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602160045260245ffd5b6008811061504457615043615006565b5b50565b5f81905061505482615033565b919050565b5f61506382615047565b9050919050565b61507381615059565b82525050565b5f60208201905061508c5f83018461506a565b92915050565b5f80604083850312156150a8576150a761486a565b5b5f6150b58582860161496c565b92505060206150c685828601614aa9565b9150509250929050565b5f6060820190506150e35f83018661492e565b6150f0602083018561492e565b6150fd604083018461492e565b949350505050565b5f60ff82169050919050565b61511a81615105565b8114615124575f80fd5b50565b5f8135905061513581615111565b92915050565b5f80604083850312156151515761515061486a565b5b5f61515e8582860161496c565b925050602061516f85828601615127565b9150509250929050565b5f80fd5b5f8083601f84011261519257615191614abd565b5b8235905067ffffffffffffffff8111156151af576151ae615179565b5b6020830191508360018202830111156151cb576151ca614cbc565b5b9250929050565b5f805f805f805f60c0888a0312156151ed576151ec61486a565b5b5f6151fa8a828b0161496c565b975050602061520b8a828b01615127565b965050604061521c8a828b01614aa9565b955050606088013567ffffffffffffffff81111561523d5761523c61486e565b5b6152498a828b0161517d565b9450945050608088013567ffffffffffffffff81111561526c5761526b61486e565b5b6152788a828b01614bbc565b92505060a088013567ffffffffffffffff8111156152995761529861486e565b5b6152a58a828b01614bbc565b91505092959891949750929550565b5f805f805f608086880312156152cd576152cc61486a565b5b5f6152da8882890161496c565b95505060206152eb88828901615127565b945050604086013567ffffffffffffffff81111561530c5761530b61486e565b5b6153188882890161517d565b9350935050606086013567ffffffffffffffff81111561533b5761533a61486e565b5b61534788828901614bbc565b9150509295509295909350565b5f65ffffffffffff82169050919050565b61536e81615354565b8114615378575f80fd5b50565b5f8135905061538981615365565b92915050565b5f602082840312156153a4576153a361486a565b5b5f6153b18482850161537b565b91505092915050565b5f805f80606085870312156153d2576153d161486a565b5b5f6153df8782880161496c565b94505060206153f087828801615127565b935050604085013567ffffffffffffffff8111156154115761541061486e565b5b61541d8782880161517d565b925092505092959194509250565b5f67ffffffffffffffff82111561544557615444614ac5565b5b61544e826149d3565b9050602081019050919050565b5f61546d6154688461542b565b614b23565b90508281526020810184848401111561548957615488614ac1565b5b615494848285614b6d565b509392505050565b5f82601f8301126154b0576154af614abd565b5b81356154c084826020860161545b565b91505092915050565b5f805f80608085870312156154e1576154e061486a565b5b5f85013567ffffffffffffffff8111156154fe576154fd61486e565b5b61550a87828801614d28565b945050602085013567ffffffffffffffff81111561552b5761552a61486e565b5b61553787828801614de8565b935050604085013567ffffffffffffffff8111156155585761555761486e565b5b61556487828801614ec6565b925050606085013567ffffffffffffffff8111156155855761558461486e565b5b6155918782880161549c565b91505092959194509250565b5f602082840312156155b2576155b161486a565b5b5f6155bf84828501614aa9565b91505092915050565b5f7fff0000000000000000000000000000000000000000000000000000000000000082169050919050565b6155fc816155c8565b82525050565b5f81519050919050565b5f82825260208201905092915050565b5f819050602082019050919050565b61563481614925565b82525050565b5f615645838361562b565b60208301905092915050565b5f602082019050919050565b5f61566782615602565b615671818561560c565b935061567c8361561c565b805f5b838110156156ac578151615693888261563a565b975061569e83615651565b92505060018101905061567f565b5085935050505092915050565b5f60e0820190506156cc5f83018a6155f3565b81810360208301526156de81896149e3565b905081810360408301526156f281886149e3565b9050615701606083018761492e565b61570e6080830186614a6b565b61571b60a0830185614fde565b81810360c083015261572d818461565d565b905098975050505050505050565b5f805f80608085870312156157535761575261486a565b5b5f6157608782880161496c565b945050602061577187828801615127565b935050604061578287828801614aa9565b925050606085013567ffffffffffffffff8111156157a3576157a261486e565b5b6157af87828801614bbc565b91505092959194509250565b6157c481615354565b82525050565b5f6020820190506157dd5f8301846157bb565b92915050565b5f805f606084860312156157fa576157f961486a565b5b5f61580786828701614aa9565b93505060206158188682870161496c565b925050604084013567ffffffffffffffff8111156158395761583861486e565b5b61584586828701614bbc565b9150509250925092565b5f61585982614a3b565b9050919050565b5f61586a8261584f565b9050919050565b61587a81615860565b8114615884575f80fd5b50565b5f8135905061589581615871565b92915050565b5f602082840312156158b0576158af61486a565b5b5f6158bd84828501615887565b91505092915050565b5f805f805f60a086880312156158df576158de61486a565b5b5f6158ec88828901614aa9565b95505060206158fd88828901614aa9565b945050604086013567ffffffffffffffff81111561591e5761591d61486e565b5b61592a88828901614de8565b935050606086013567ffffffffffffffff81111561594b5761594a61486e565b5b61595788828901614de8565b925050608086013567ffffffffffffffff8111156159785761597761486e565b5b61598488828901614bbc565b9150509295509295909350565b5f8083601f8401126159a6576159a5614abd565b5b8235905067ffffffffffffffff8111156159c3576159c2615179565b5b6020830191508360018202830111156159df576159de614cbc565b5b9250929050565b5f805f80606085870312156159fe576159fd61486a565b5b5f615a0b87828801614aa9565b9450506020615a1c8782880161496c565b935050604085013567ffffffffffffffff811115615a3d57615a3c61486e565b5b615a4987828801615991565b925092505092959194509250565b5f63ffffffff82169050919050565b615a6f81615a57565b8114615a79575f80fd5b50565b5f81359050615a8a81615a66565b92915050565b5f60208284031215615aa557615aa461486a565b5b5f615ab284828501615a7c565b91505092915050565b5f8060408385031215615ad157615ad061486a565b5b5f615ade85828601614aa9565b9250506020615aef8582860161496c565b9150509250929050565b5f805f805f60a08688031215615b1257615b1161486a565b5b5f615b1f88828901614aa9565b9550506020615b3088828901614aa9565b9450506040615b418882890161496c565b9350506060615b528882890161496c565b925050608086013567ffffffffffffffff811115615b7357615b7261486e565b5b615b7f88828901614bbc565b9150509295509295909350565b5f819050919050565b5f615baf615baa615ba584614a3b565b615b8c565b614a3b565b9050919050565b5f615bc082615b95565b9050919050565b5f615bd182615bb6565b9050919050565b615be181615bc7565b82525050565b5f602082019050615bfa5f830184615bd8565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602260045260245ffd5b5f6002820490506001821680615c4457607f821691505b602082108103615c5757615c56615c00565b5b50919050565b5f615c77615c72615c6d84615354565b615b8c565b614925565b9050919050565b615c8781615c5d565b82525050565b5f604082019050615ca05f83018561492e565b615cad6020830184615c7e565b9392505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52603260045260245ffd5b5f615cf3615cee8461542b565b614b23565b905082815260208101848484011115615d0f57615d0e614ac1565b5b615d1a8482856149c5565b509392505050565b5f82601f830112615d3657615d35614abd565b5b8151615d46848260208601615ce1565b91505092915050565b5f60208284031215615d6457615d6361486a565b5b5f82015167ffffffffffffffff811115615d8157615d8061486e565b5b615d8d84828501615d22565b91505092915050565b5f81905092915050565b5f615dab8385615d96565b9350615db8838584614b6d565b82840190509392505050565b5f615dd0828486615da0565b91508190509392505050565b615de581615105565b82525050565b5f60e082019050615dfe5f83018a614fde565b615e0b602083018961492e565b615e186040830188615ddc565b615e256060830187614a6b565b615e32608083018661492e565b615e3f60a0830185614fde565b615e4c60c0830184614fde565b98975050505050505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f615e8f82614925565b9150615e9a83614925565b9250828203905081811115615eb257615eb1615e58565b5b92915050565b5f615ec282615354565b9150615ecd83615354565b9250828203905065ffffffffffff811115615eeb57615eea615e58565b5b92915050565b5f606082019050615f045f830186614a6b565b615f11602083018561492e565b615f1e604083018461492e565b949350505050565b5f60a082019050615f395f830188614fde565b615f46602083018761492e565b615f536040830186615ddc565b615f606060830185614a6b565b615f6d608083018461492e565b9695505050505050565b5f81519050615f8581615365565b92915050565b5f60208284031215615fa057615f9f61486a565b5b5f615fad84828501615f77565b91505092915050565b5f615fc082615354565b9150615fcb83615354565b9250828201905065ffffffffffff811115615fe957615fe8615e58565b5b92915050565b5f81519050919050565b5f82825260208201905092915050565b5f819050602082019050919050565b61602181614a5a565b82525050565b5f6160328383616018565b60208301905092915050565b5f602082019050919050565b5f61605482615fef565b61605e8185615ff9565b935061606983616009565b805f5b838110156160995781516160808882616027565b975061608b8361603e565b92505060018101905061606c565b5085935050505092915050565b5f81519050919050565b5f82825260208201905092915050565b5f819050602082019050919050565b5f81519050919050565b5f82825260208201905092915050565b5f6160f3826160cf565b6160fd81856160d9565b935061610d8185602086016149c5565b616116816149d3565b840191505092915050565b5f61612c83836160e9565b905092915050565b5f602082019050919050565b5f61614a826160a6565b61615481856160b0565b935083602082028501616166856160c0565b805f5b858110156161a157848403895281516161828582616121565b945061618d83616134565b925060208a01995050600181019050616169565b50829750879550505050505092915050565b5f6080820190508181035f8301526161cb818761604a565b905081810360208301526161df818661565d565b905081810360408301526161f38185616140565b90506162026060830184614fde565b95945050505050565b5f60408201905061621e5f83018561492e565b61622b602083018461492e565b9392505050565b5f6060820190506162455f83018661492e565b616252602083018561506a565b61625f6040830184614fde565b949350505050565b616270816148f2565b811461627a575f80fd5b50565b5f8151905061628b81616267565b92915050565b5f602082840312156162a6576162a561486a565b5b5f6162b38482850161627d565b91505092915050565b5f6080820190506162cf5f83018761492e565b6162dc6020830186615ddc565b6162e9604083018561492e565b81810360608301526162fb81846149e3565b905095945050505050565b5f82825260208201905092915050565b5f616320826160cf565b61632a8185616306565b935061633a8185602086016149c5565b616343816149d3565b840191505092915050565b5f60a0820190506163615f83018861492e565b61636e6020830187615ddc565b61637b604083018661492e565b818103606083015261638d81856149e3565b905081810360808301526163a18184616316565b90509695505050505050565b5f819050919050565b5f6163d06163cb6163c6846163ad565b615b8c565b615105565b9050919050565b6163e0816163b6565b82525050565b5f6040820190506163f95f8301856163d7565b616406602083018461492e565b9392505050565b5f61641782614925565b915061642283614925565b925082820190508082111561643a57616439615e58565b5b92915050565b5f6040820190506164535f830185615c7e565b6164606020830184615c7e565b9392505050565b5f81519050919050565b5f82825260208201905092915050565b5f819050602082019050919050565b5f82825260208201905092915050565b5f6164aa826149ab565b6164b48185616490565b93506164c48185602086016149c5565b6164cd816149d3565b840191505092915050565b5f6164e383836164a0565b905092915050565b5f602082019050919050565b5f61650182616467565b61650b8185616471565b93508360208202850161651d85616481565b805f5b85811015616558578484038952815161653985826164d8565b9450616544836164eb565b925060208a01995050600181019050616520565b50829750879550505050505092915050565b5f6101208201905061657e5f83018c61492e565b61658b602083018b614a6b565b818103604083015261659d818a61604a565b905081810360608301526165b1818961565d565b905081810360808301526165c581886164f7565b905081810360a08301526165d98187616140565b90506165e860c083018661492e565b6165f560e083018561492e565b81810361010083015261660881846149e3565b90509a9950505050505050505050565b5f60408201905061662b5f830185614a6b565b616638602083018461492e565b9392505050565b5f8151905061664d81614956565b92915050565b5f602082840312156166685761666761486a565b5b5f6166758482850161663f565b91505092915050565b5f6040820190506166915f830185614a6b565b61669e6020830184614a6b565b9392505050565b5f819050919050565b5f6166c86166c36166be846166a5565b615b8c565b614925565b9050919050565b6166d8816166ae565b82525050565b5f6020820190506166f15f8301846166cf565b92915050565b5f61671161670c61670784615a57565b615b8c565b614925565b9050919050565b616721816166f7565b82525050565b5f60408201905061673a5f830185616718565b6167476020830184616718565b9392505050565b5f61675882614925565b915061676383614925565b925082820261677181614925565b9150828204841483151761678857616787615e58565b5b5092915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601260045260245ffd5b5f6167c682614925565b91506167d183614925565b9250826167e1576167e061678f565b5b828204905092915050565b5f819050919050565b5f61680f61680a616805846167ec565b615b8c565b615105565b9050919050565b61681f816167f5565b82525050565b5f6040820190506168385f830185616816565b616845602083018461492e565b9392505050565b5f815f1b9050919050565b5f61687161686c616867846166a5565b61684c565b614ef3565b9050919050565b61688181616857565b82525050565b5f60a0820190508181035f83015261689f818861604a565b905081810360208301526168b3818761565d565b905081810360408301526168c78186616140565b90506168d66060830185616878565b6168e36080830184614fde565b9695505050505050565b5f815190506168fb81614efc565b92915050565b5f602082840312156169165761691561486a565b5b5f616923848285016168ed565b91505092915050565b5f60c0820190508181035f830152616944818961604a565b90508181036020830152616958818861565d565b9050818103604083015261696c8187616140565b905061697b6060830186616878565b6169886080830185614fde565b61699560a083018461492e565b979650505050505050565b5f6040820190506169b35f830185614fde565b81810360208301526169c58184616316565b90509392505050565b5f6169d8826160cf565b6169e28185615d96565b93506169f28185602086016149c5565b80840191505092915050565b5f616a0982846169ce565b915081905092915050565b5f819050919050565b5f616a37616a32616a2d84616a14565b615b8c565b615105565b9050919050565b616a4781616a1d565b82525050565b5f604082019050616a605f830185616a3e565b616a6d602083018461492e565b9392505050565b5f616a7e82615105565b9150616a8983615105565b9250828201905060ff811115616aa257616aa1615e58565b5b92915050565b5f8160011c9050919050565b5f808291508390505b6001851115616afd57808604811115616ad957616ad8615e58565b5b6001851615616ae85780820291505b8081029050616af685616aa8565b9450616abd565b94509492505050565b5f82616b155760019050616bd0565b81616b22575f9050616bd0565b8160018114616b385760028114616b4257616b71565b6001915050616bd0565b60ff841115616b5457616b53615e58565b5b8360020a915084821115616b6b57616b6a615e58565b5b50616bd0565b5060208310610133831016604e8410600b8410161715616ba65782820a905083811115616ba157616ba0615e58565b5b616bd0565b616bb38484846001616ab4565b92509050818404811115616bca57616bc9615e58565b5b81810290505b9392505050565b5f616be182614925565b9150616bec83615105565b9250616c197fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8484616b06565b905092915050565b5f60a082019050616c345f830188614fde565b616c416020830187614fde565b616c4e6040830186614fde565b616c5b606083018561492e565b616c686080830184614a6b565b9695505050505050565b5f608082019050616c855f830187614fde565b616c926020830186615ddc565b616c9f6040830185614fde565b616cac6060830184614fde565b9594505050505056fea2646970667358221220471c208304acea3054fd5039e7773c86282be71dcf4100ca1f8b478f208e066f64736f6c634300081a0033";
String timelockBytecodeGlobal =
    "608060405234801561000f575f80fd5b506040516130c33803806130c383398181016040528101906100319190610530565b6100435f801b306101e360201b60201c565b505f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161461008b576100895f801b826101e360201b60201c565b505b5f5b8351811015610137576100e07fb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc18583815181106100cd576100cc6105cc565b5b60200260200101516101e360201b60201c565b5061012b7ffd643c72710c63c0180259aba6b2d05451e3591a24e58b62239378085726f783858381518110610118576101176105cc565b5b60200260200101516101e360201b60201c565b5080600101905061008d565b505f5b82518110156101995761018d7fd8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e6384838151811061017a576101796105cc565b5b60200260200101516101e360201b60201c565b5080600101905061013a565b50836002819055507f11c24f4ead16507c69ac467fbd5e4eed5fb5c699626d2cc6d66421df253886d55f856040516101d292919061064a565b60405180910390a150505050610671565b5f6101f483836102d860201b60201c565b6102ce5760015f808581526020019081526020015f205f015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f6101000a81548160ff02191690831515021790555061026b61033b60201b60201c565b73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16847f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a4600190506102d2565b5f90505b92915050565b5f805f8481526020019081526020015f205f015f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900460ff16905092915050565b5f33905090565b5f604051905090565b5f80fd5b5f80fd5b5f819050919050565b61036581610353565b811461036f575f80fd5b50565b5f815190506103808161035c565b92915050565b5f80fd5b5f601f19601f8301169050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b6103d08261038a565b810181811067ffffffffffffffff821117156103ef576103ee61039a565b5b80604052505050565b5f610401610342565b905061040d82826103c7565b919050565b5f67ffffffffffffffff82111561042c5761042b61039a565b5b602082029050602081019050919050565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f61046a82610441565b9050919050565b61047a81610460565b8114610484575f80fd5b50565b5f8151905061049581610471565b92915050565b5f6104ad6104a884610412565b6103f8565b905080838252602082019050602084028301858111156104d0576104cf61043d565b5b835b818110156104f957806104e58882610487565b8452602084019350506020810190506104d2565b5050509392505050565b5f82601f83011261051757610516610386565b5b815161052784826020860161049b565b91505092915050565b5f805f80608085870312156105485761054761034b565b5b5f61055587828801610372565b945050602085015167ffffffffffffffff8111156105765761057561034f565b5b61058287828801610503565b935050604085015167ffffffffffffffff8111156105a3576105a261034f565b5b6105af87828801610503565b92505060606105c087828801610487565b91505092959194509250565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52603260045260245ffd5b5f819050919050565b5f819050919050565b5f61062561062061061b846105f9565b610602565b610353565b9050919050565b6106358161060b565b82525050565b61064481610353565b82525050565b5f60408201905061065d5f83018561062c565b61066a602083018461063b565b9392505050565b612a458061067e5f395ff3fe6080604052600436106101ba575f3560e01c80638065657f116100eb578063bc197c8111610089578063d547741f11610063578063d547741f14610685578063e38335e5146106ad578063f23a6e61146106c9578063f27a0c9214610705576101c1565b8063bc197c81146105e5578063c4d252f514610621578063d45c443514610649576101c1565b806391d14854116100c557806391d1485414610519578063a217fddf14610555578063b08e51c01461057f578063b1c5f427146105a9576101c1565b80638065657f1461048b5780638f2a0bb0146104c75780638f61f4f5146104ef576101c1565b80632ab0f5291161015857806336568abe1161013257806336568abe146103c3578063584b153e146103eb57806364d62353146104275780637958004c1461044f576101c1565b80632ab0f529146103235780632f2ff15d1461035f57806331d5075014610387576101c1565b8063134008d311610194578063134008d31461025357806313bc9f201461026f578063150b7a02146102ab578063248a9ca3146102e7576101c1565b806301d5062a146101c557806301ffc9a7146101ed57806307bd026514610229576101c1565b366101c157005b5f80fd5b3480156101d0575f80fd5b506101eb60048036038101906101e6919061198b565b61072f565b005b3480156101f8575f80fd5b50610213600480360381019061020e9190611a8a565b610804565b6040516102209190611acf565b60405180910390f35b348015610234575f80fd5b5061023d610815565b60405161024a9190611af7565b60405180910390f35b61026d60048036038101906102689190611b10565b610839565b005b34801561027a575f80fd5b5061029560048036038101906102909190611ba6565b6108f3565b6040516102a29190611acf565b60405180910390f35b3480156102b6575f80fd5b506102d160048036038101906102cc9190611d09565b61092b565b6040516102de9190611d98565b60405180910390f35b3480156102f2575f80fd5b5061030d60048036038101906103089190611ba6565b61093e565b60405161031a9190611af7565b60405180910390f35b34801561032e575f80fd5b5061034960048036038101906103449190611ba6565b61095a565b6040516103569190611acf565b60405180910390f35b34801561036a575f80fd5b5061038560048036038101906103809190611db1565b610991565b005b348015610392575f80fd5b506103ad60048036038101906103a89190611ba6565b6109b3565b6040516103ba9190611acf565b60405180910390f35b3480156103ce575f80fd5b506103e960048036038101906103e49190611db1565b6109eb565b005b3480156103f6575f80fd5b50610411600480360381019061040c9190611ba6565b610a66565b60405161041e9190611acf565b60405180910390f35b348015610432575f80fd5b5061044d60048036038101906104489190611def565b610ad2565b005b34801561045a575f80fd5b5061047560048036038101906104709190611ba6565b610b93565b6040516104829190611e8d565b60405180910390f35b348015610496575f80fd5b506104b160048036038101906104ac9190611b10565b610bdf565b6040516104be9190611af7565b60405180910390f35b3480156104d2575f80fd5b506104ed60048036038101906104e89190611fa5565b610c1d565b005b3480156104fa575f80fd5b50610503610ddc565b6040516105109190611af7565b60405180910390f35b348015610524575f80fd5b5061053f600480360381019061053a9190611db1565b610e00565b60405161054c9190611acf565b60405180910390f35b348015610560575f80fd5b50610569610e63565b6040516105769190611af7565b60405180910390f35b34801561058a575f80fd5b50610593610e69565b6040516105a09190611af7565b60405180910390f35b3480156105b4575f80fd5b506105cf60048036038101906105ca919061208e565b610e8d565b6040516105dc9190611af7565b60405180910390f35b3480156105f0575f80fd5b5061060b60048036038101906106069190612225565b610ed1565b6040516106189190611d98565b60405180910390f35b34801561062c575f80fd5b5061064760048036038101906106429190611ba6565b610ee5565b005b348015610654575f80fd5b5061066f600480360381019061066a9190611ba6565b610fb4565b60405161067c91906122ff565b60405180910390f35b348015610690575f80fd5b506106ab60048036038101906106a69190611db1565b610fce565b005b6106c760048036038101906106c2919061208e565b610ff0565b005b3480156106d4575f80fd5b506106ef60048036038101906106ea9190612318565b6111a8565b6040516106fc9190611d98565b60405180910390f35b348015610710575f80fd5b506107196111bc565b60405161072691906122ff565b60405180910390f35b7fb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1610759816111c5565b5f610768898989898989610bdf565b905061077481846111d9565b5f817f4cf4410cc57040e44862ef0f45f3dd5a5e02db8eb8add648d4b0e236f1d07dca8b8b8b8b8b8a6040516107af969594939291906123f6565b60405180910390a35f801b84146107f957807f20fda5fd27a1ea7bf5b9567f143ac5470bb059374a27e8f67cb44f946f6d0387856040516107f09190611af7565b60405180910390a25b505050505050505050565b5f61080e826112a6565b9050919050565b7fd8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e6381565b7fd8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e63610864815f610e00565b61087a576108798161087461131f565b611326565b5b5f610889888888888888610bdf565b90506108958185611377565b6108a18888888861142a565b5f817fc2617efa69bab66782fa219543714338489c4e9e178271560a91b82c3f612b588a8a8a8a6040516108d89493929190612450565b60405180910390a36108e9816114ab565b5050505050505050565b5f6002600381111561090857610907611e1a565b5b61091183610b93565b600381111561092357610922611e1a565b5b149050919050565b5f63150b7a0260e01b9050949350505050565b5f805f8381526020019081526020015f20600101549050919050565b5f60038081111561096e5761096d611e1a565b5b61097783610b93565b600381111561098957610988611e1a565b5b149050919050565b61099a8261093e565b6109a3816111c5565b6109ad8383611519565b50505050565b5f8060038111156109c7576109c6611e1a565b5b6109d083610b93565b60038111156109e2576109e1611e1a565b5b14159050919050565b6109f361131f565b73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614610a57576040517f6697b23200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b610a618282611602565b505050565b5f80610a7183610b93565b905060016003811115610a8757610a86611e1a565b5b816003811115610a9a57610a99611e1a565b5b1480610aca575060026003811115610ab557610ab4611e1a565b5b816003811115610ac857610ac7611e1a565b5b145b915050919050565b5f610adb61131f565b90503073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614610b4d57806040517fe2850c59000000000000000000000000000000000000000000000000000000008152600401610b44919061248e565b60405180910390fd5b7f11c24f4ead16507c69ac467fbd5e4eed5fb5c699626d2cc6d66421df253886d560025483604051610b809291906124a7565b60405180910390a1816002819055505050565b5f80610b9e83610fb4565b90505f8103610bb0575f915050610bda565b60018103610bc2576003915050610bda565b42811115610bd4576001915050610bda565b60029150505b919050565b5f868686868686604051602001610bfb969594939291906124ce565b6040516020818303038152906040528051906020012090509695505050505050565b7fb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1610c47816111c5565b878790508a8a9050141580610c625750858590508a8a905014155b15610cb1578989905086869050898990506040517fffb03211000000000000000000000000000000000000000000000000000000008152600401610ca893929190612528565b60405180910390fd5b5f610cc28b8b8b8b8b8b8b8b610e8d565b9050610cce81846111d9565b5f5b8b8b9050811015610d8c5780827f4cf4410cc57040e44862ef0f45f3dd5a5e02db8eb8add648d4b0e236f1d07dca8e8e85818110610d1157610d1061255d565b5b9050602002016020810190610d26919061258a565b8d8d86818110610d3957610d3861255d565b5b905060200201358c8c87818110610d5357610d5261255d565b5b9050602002810190610d6591906125c1565b8c8b604051610d79969594939291906123f6565b60405180910390a3806001019050610cd0565b505f801b8414610dcf57807f20fda5fd27a1ea7bf5b9567f143ac5470bb059374a27e8f67cb44f946f6d038785604051610dc69190611af7565b60405180910390a25b5050505050505050505050565b7fb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc181565b5f805f8481526020019081526020015f205f015f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900460ff16905092915050565b5f801b81565b7ffd643c72710c63c0180259aba6b2d05451e3591a24e58b62239378085726f78381565b5f8888888888888888604051602001610ead9897969594939291906128af565b60405160208183030381529060405280519060200120905098975050505050505050565b5f63bc197c8160e01b905095945050505050565b7ffd643c72710c63c0180259aba6b2d05451e3591a24e58b62239378085726f783610f0f816111c5565b610f1882610a66565b610f6f5781610f2760026116eb565b610f3160016116eb565b176040517f5ead8eb5000000000000000000000000000000000000000000000000000000008152600401610f6692919061291b565b60405180910390fd5b60015f8381526020019081526020015f205f9055817fbaa1eb22f2a492ba1a5fea61b8df4d27c6c8b5f3971e63bb58fa14ff72eedb7060405160405180910390a25050565b5f60015f8381526020019081526020015f20549050919050565b610fd78261093e565b610fe0816111c5565b610fea8383611602565b50505050565b7fd8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e6361101b815f610e00565b611031576110308161102b61131f565b611326565b5b868690508989905014158061104c5750848490508989905014155b1561109b578888905085859050888890506040517fffb0321100000000000000000000000000000000000000000000000000000000815260040161109293929190612528565b60405180910390fd5b5f6110ac8a8a8a8a8a8a8a8a610e8d565b90506110b88185611377565b5f5b8a8a9050811015611192575f8b8b838181106110d9576110d861255d565b5b90506020020160208101906110ee919061258a565b90505f8a8a848181106111045761110361255d565b5b905060200201359050365f8a8a868181106111225761112161255d565b5b905060200281019061113491906125c1565b915091506111448484848461142a565b84867fc2617efa69bab66782fa219543714338489c4e9e178271560a91b82c3f612b588686868660405161117b9493929190612450565b60405180910390a3505050508060010190506110ba565b5061119c816114ab565b50505050505050505050565b5f63f23a6e6160e01b905095945050505050565b5f600254905090565b6111d6816111d161131f565b611326565b50565b6111e2826109b3565b1561122e57816111f15f6116eb565b6040517f5ead8eb500000000000000000000000000000000000000000000000000000000815260040161122592919061291b565b60405180910390fd5b5f6112376111bc565b9050808210156112805781816040517f543366090000000000000000000000000000000000000000000000000000000081526004016112779291906124a7565b60405180910390fd5b814261128c919061296f565b60015f8581526020019081526020015f2081905550505050565b5f7f4e2312e0000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916148061131857506113178261170f565b5b9050919050565b5f33905090565b6113308282610e00565b6113735780826040517fe2517d3f00000000000000000000000000000000000000000000000000000000815260040161136a9291906129a2565b60405180910390fd5b5050565b611380826108f3565b6113cc578161138f60026116eb565b6040517f5ead8eb50000000000000000000000000000000000000000000000000000000081526004016113c392919061291b565b60405180910390fd5b5f801b81141580156113e457506113e28161095a565b155b1561142657806040517f90a9a61800000000000000000000000000000000000000000000000000000000815260040161141d9190611af7565b60405180910390fd5b5050565b5f808573ffffffffffffffffffffffffffffffffffffffff168585856040516114549291906129f7565b5f6040518083038185875af1925050503d805f811461148e576040519150601f19603f3d011682016040523d82523d5f602084013e611493565b606091505b50915091506114a28282611788565b50505050505050565b6114b4816108f3565b61150057806114c360026116eb565b6040517f5ead8eb50000000000000000000000000000000000000000000000000000000081526004016114f792919061291b565b60405180910390fd5b6001805f8381526020019081526020015f208190555050565b5f6115248383610e00565b6115f85760015f808581526020019081526020015f205f015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f6101000a81548160ff02191690831515021790555061159561131f565b73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16847f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a4600190506115fc565b5f90505b92915050565b5f61160d8383610e00565b156116e1575f805f8581526020019081526020015f205f015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f6101000a81548160ff02191690831515021790555061167e61131f565b73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16847ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b60405160405180910390a4600190506116e5565b5f90505b92915050565b5f8160038111156116ff576116fe611e1a565b5b60ff166001901b5f1b9050919050565b5f7f7965db0b000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff191614806117815750611780826117ac565b5b9050919050565b60608261179d5761179882611815565b6117a5565b8190506117a6565b5b92915050565b5f7f01ffc9a7000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916149050919050565b5f815111156118275780518082602001fd5b6040517f1425ea4200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5f604051905090565b5f80fd5b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f6118938261186a565b9050919050565b6118a381611889565b81146118ad575f80fd5b50565b5f813590506118be8161189a565b92915050565b5f819050919050565b6118d6816118c4565b81146118e0575f80fd5b50565b5f813590506118f1816118cd565b92915050565b5f80fd5b5f80fd5b5f80fd5b5f8083601f840112611918576119176118f7565b5b8235905067ffffffffffffffff811115611935576119346118fb565b5b602083019150836001820283011115611951576119506118ff565b5b9250929050565b5f819050919050565b61196a81611958565b8114611974575f80fd5b50565b5f8135905061198581611961565b92915050565b5f805f805f805f60c0888a0312156119a6576119a5611862565b5b5f6119b38a828b016118b0565b97505060206119c48a828b016118e3565b965050604088013567ffffffffffffffff8111156119e5576119e4611866565b5b6119f18a828b01611903565b95509550506060611a048a828b01611977565b9350506080611a158a828b01611977565b92505060a0611a268a828b016118e3565b91505092959891949750929550565b5f7fffffffff0000000000000000000000000000000000000000000000000000000082169050919050565b611a6981611a35565b8114611a73575f80fd5b50565b5f81359050611a8481611a60565b92915050565b5f60208284031215611a9f57611a9e611862565b5b5f611aac84828501611a76565b91505092915050565b5f8115159050919050565b611ac981611ab5565b82525050565b5f602082019050611ae25f830184611ac0565b92915050565b611af181611958565b82525050565b5f602082019050611b0a5f830184611ae8565b92915050565b5f805f805f8060a08789031215611b2a57611b29611862565b5b5f611b3789828a016118b0565b9650506020611b4889828a016118e3565b955050604087013567ffffffffffffffff811115611b6957611b68611866565b5b611b7589828a01611903565b94509450506060611b8889828a01611977565b9250506080611b9989828a01611977565b9150509295509295509295565b5f60208284031215611bbb57611bba611862565b5b5f611bc884828501611977565b91505092915050565b5f80fd5b5f601f19601f8301169050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b611c1b82611bd5565b810181811067ffffffffffffffff82111715611c3a57611c39611be5565b5b80604052505050565b5f611c4c611859565b9050611c588282611c12565b919050565b5f67ffffffffffffffff821115611c7757611c76611be5565b5b611c8082611bd5565b9050602081019050919050565b828183375f83830152505050565b5f611cad611ca884611c5d565b611c43565b905082815260208101848484011115611cc957611cc8611bd1565b5b611cd4848285611c8d565b509392505050565b5f82601f830112611cf057611cef6118f7565b5b8135611d00848260208601611c9b565b91505092915050565b5f805f8060808587031215611d2157611d20611862565b5b5f611d2e878288016118b0565b9450506020611d3f878288016118b0565b9350506040611d50878288016118e3565b925050606085013567ffffffffffffffff811115611d7157611d70611866565b5b611d7d87828801611cdc565b91505092959194509250565b611d9281611a35565b82525050565b5f602082019050611dab5f830184611d89565b92915050565b5f8060408385031215611dc757611dc6611862565b5b5f611dd485828601611977565b9250506020611de5858286016118b0565b9150509250929050565b5f60208284031215611e0457611e03611862565b5b5f611e11848285016118e3565b91505092915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602160045260245ffd5b60048110611e5857611e57611e1a565b5b50565b5f819050611e6882611e47565b919050565b5f611e7782611e5b565b9050919050565b611e8781611e6d565b82525050565b5f602082019050611ea05f830184611e7e565b92915050565b5f8083601f840112611ebb57611eba6118f7565b5b8235905067ffffffffffffffff811115611ed857611ed76118fb565b5b602083019150836020820283011115611ef457611ef36118ff565b5b9250929050565b5f8083601f840112611f1057611f0f6118f7565b5b8235905067ffffffffffffffff811115611f2d57611f2c6118fb565b5b602083019150836020820283011115611f4957611f486118ff565b5b9250929050565b5f8083601f840112611f6557611f646118f7565b5b8235905067ffffffffffffffff811115611f8257611f816118fb565b5b602083019150836020820283011115611f9e57611f9d6118ff565b5b9250929050565b5f805f805f805f805f60c08a8c031215611fc257611fc1611862565b5b5f8a013567ffffffffffffffff811115611fdf57611fde611866565b5b611feb8c828d01611ea6565b995099505060208a013567ffffffffffffffff81111561200e5761200d611866565b5b61201a8c828d01611efb565b975097505060408a013567ffffffffffffffff81111561203d5761203c611866565b5b6120498c828d01611f50565b9550955050606061205c8c828d01611977565b935050608061206d8c828d01611977565b92505060a061207e8c828d016118e3565b9150509295985092959850929598565b5f805f805f805f8060a0898b0312156120aa576120a9611862565b5b5f89013567ffffffffffffffff8111156120c7576120c6611866565b5b6120d38b828c01611ea6565b9850985050602089013567ffffffffffffffff8111156120f6576120f5611866565b5b6121028b828c01611efb565b9650965050604089013567ffffffffffffffff81111561212557612124611866565b5b6121318b828c01611f50565b945094505060606121448b828c01611977565b92505060806121558b828c01611977565b9150509295985092959890939650565b5f67ffffffffffffffff82111561217f5761217e611be5565b5b602082029050602081019050919050565b5f6121a261219d84612165565b611c43565b905080838252602082019050602084028301858111156121c5576121c46118ff565b5b835b818110156121ee57806121da88826118e3565b8452602084019350506020810190506121c7565b5050509392505050565b5f82601f83011261220c5761220b6118f7565b5b813561221c848260208601612190565b91505092915050565b5f805f805f60a0868803121561223e5761223d611862565b5b5f61224b888289016118b0565b955050602061225c888289016118b0565b945050604086013567ffffffffffffffff81111561227d5761227c611866565b5b612289888289016121f8565b935050606086013567ffffffffffffffff8111156122aa576122a9611866565b5b6122b6888289016121f8565b925050608086013567ffffffffffffffff8111156122d7576122d6611866565b5b6122e388828901611cdc565b9150509295509295909350565b6122f9816118c4565b82525050565b5f6020820190506123125f8301846122f0565b92915050565b5f805f805f60a0868803121561233157612330611862565b5b5f61233e888289016118b0565b955050602061234f888289016118b0565b9450506040612360888289016118e3565b9350506060612371888289016118e3565b925050608086013567ffffffffffffffff81111561239257612391611866565b5b61239e88828901611cdc565b9150509295509295909350565b6123b481611889565b82525050565b5f82825260208201905092915050565b5f6123d583856123ba565b93506123e2838584611c8d565b6123eb83611bd5565b840190509392505050565b5f60a0820190506124095f8301896123ab565b61241660208301886122f0565b81810360408301526124298186886123ca565b90506124386060830185611ae8565b61244560808301846122f0565b979650505050505050565b5f6060820190506124635f8301876123ab565b61247060208301866122f0565b81810360408301526124838184866123ca565b905095945050505050565b5f6020820190506124a15f8301846123ab565b92915050565b5f6040820190506124ba5f8301856122f0565b6124c760208301846122f0565b9392505050565b5f60a0820190506124e15f8301896123ab565b6124ee60208301886122f0565b81810360408301526125018186886123ca565b90506125106060830185611ae8565b61251d6080830184611ae8565b979650505050505050565b5f60608201905061253b5f8301866122f0565b61254860208301856122f0565b61255560408301846122f0565b949350505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52603260045260245ffd5b5f6020828403121561259f5761259e611862565b5b5f6125ac848285016118b0565b91505092915050565b5f80fd5b5f80fd5b5f80fd5b5f80833560016020038436030381126125dd576125dc6125b5565b5b80840192508235915067ffffffffffffffff8211156125ff576125fe6125b9565b5b60208301925060018202360383131561261b5761261a6125bd565b5b509250929050565b5f82825260208201905092915050565b5f819050919050565b61264581611889565b82525050565b5f612656838361263c565b60208301905092915050565b5f61267060208401846118b0565b905092915050565b5f602082019050919050565b5f61268f8385612623565b935061269a82612633565b805f5b858110156126d2576126af8284612662565b6126b9888261264b565b97506126c483612678565b92505060018101905061269d565b5085925050509392505050565b5f82825260208201905092915050565b5f80fd5b82818337505050565b5f61270783856126df565b93507f07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff83111561273a576127396126ef565b5b60208302925061274b8385846126f3565b82840190509392505050565b5f82825260208201905092915050565b5f819050919050565b5f82825260208201905092915050565b5f61278b8385612770565b9350612798838584611c8d565b6127a183611bd5565b840190509392505050565b5f6127b8848484612780565b90509392505050565b5f80fd5b5f80fd5b5f80fd5b5f80833560016020038436030381126127e9576127e86127c9565b5b83810192508235915060208301925067ffffffffffffffff821115612811576128106127c1565b5b600182023603831315612827576128266127c5565b5b509250929050565b5f602082019050919050565b5f6128468385612757565b93508360208402850161285884612767565b805f5b8781101561289d57848403895261287282846127cd565b61287d8682846127ac565b95506128888461282f565b935060208b019a50505060018101905061285b565b50829750879450505050509392505050565b5f60a0820190508181035f8301526128c8818a8c612684565b905081810360208301526128dd81888a6126fc565b905081810360408301526128f281868861283b565b90506129016060830185611ae8565b61290e6080830184611ae8565b9998505050505050505050565b5f60408201905061292e5f830185611ae8565b61293b6020830184611ae8565b9392505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f612979826118c4565b9150612984836118c4565b925082820190508082111561299c5761299b612942565b5b92915050565b5f6040820190506129b55f8301856123ab565b6129c26020830184611ae8565b9392505050565b5f81905092915050565b5f6129de83856129c9565b93506129eb838584611c8d565b82840190509392505050565b5f612a038284866129d3565b9150819050939250505056fea2646970667358221220e6fa09805d3524b4605c652dede1321fb78e24a79c46f55774f0ec93a644cee364736f6c634300081a0033";
String tokenBytecodeGlobal =
    "610160604052348015610010575f80fd5b506040516154323803806154328339818101604052810190610032919061136f565b83806040518060400160405280600181526020017f31000000000000000000000000000000000000000000000000000000000000008152508686816003908161007b9190611647565b50806004908161008b9190611647565b5050506100a26005836101fb60201b90919060201c565b61012081815250506100be6006826101fb60201b90919060201c565b6101408181525050818051906020012060e08181525050808051906020012061010081815250504660a081815250506100fb61024860201b60201c565b608081815250503073ffffffffffffffffffffffffffffffffffffffff1660c08173ffffffffffffffffffffffffffffffffffffffff1681525050505050805182511461017d576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161017490611796565b60405180910390fd5b5f5b82518163ffffffff1610156101f1576101de838263ffffffff16815181106101aa576101a96117b4565b5b6020026020010151838363ffffffff16815181106101cb576101ca6117b4565b5b60200260200101516102a260201b60201c565b80806101e99061181d565b91505061017f565b5050505050611c39565b5f60208351101561021c576102158361032760201b60201c565b9050610242565b8261022c8361038c60201b60201c565b5f01908161023a9190611647565b5060ff5f1b90505b92915050565b5f7f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f60e05161010051463060405160200161028795949392919061187e565b60405160208183030381529060405280519060200120905090565b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610312575f6040517fec442f0500000000000000000000000000000000000000000000000000000000815260040161030991906118cf565b60405180910390fd5b6103235f838361039560201b60201c565b5050565b5f80829050601f8151111561037357826040517f305a27a900000000000000000000000000000000000000000000000000000000815260040161036a9190611920565b60405180910390fd5b80518161037f9061196d565b5f1c175f1b915050919050565b5f819050919050565b6103a68383836103ab60201b60201c565b505050565b6103bc83838361047160201b60201c565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff160361045b575f6103fe61068a60201b60201c565b90505f61040f61069360201b60201c565b9050808211156104585781816040517f1cb15d2600000000000000000000000000000000000000000000000000000000815260040161044f9291906119d3565b60405180910390fd5b50505b61046c8383836106b660201b60201c565b505050565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16036104c1578060025f8282546104b591906119fa565b9250508190555061058f565b5f805f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205490508181101561054a578381836040517fe450d38c00000000000000000000000000000000000000000000000000000000815260040161054193929190611a2d565b60405180910390fd5b8181035f808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2081905550505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16036105d6578060025f8282540392505081905550610620565b805f808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825401925050819055505b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8360405161067d9190611a62565b60405180910390a3505050565b5f600254905090565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff8016905090565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff160361071557610712600a6107a660201b610d6a17610707846107bb60201b60201c565b61082860201b60201c565b50505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160361077457610771600a61087060201b610d7f17610766846107bb60201b60201c565b61082860201b60201c565b50505b6107a16107868461088560201b60201c565b6107958461088560201b60201c565b836108ea60201b60201c565b505050565b5f81836107b39190611aa0565b905092915050565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff80168211156108205760d0826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401610817929190611b32565b60405180910390fd5b819050919050565b5f8061086461083b610b8060201b60201c565b61085461084d88610b9460201b60201c565b868860201c565b87610bfc60201b9092919060201c565b91509150935093915050565b5f818361087d9190611b59565b905092915050565b5f60085f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415801561092557505f81115b15610b7b575f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614610a52575f806109c360095f8773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2061087060201b610d7f176109b8866107bb60201b60201c565b61082860201b60201c565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16915079ffffffffffffffffffffffffffffffffffffffffffffffffffff1691508473ffffffffffffffffffffffffffffffffffffffff167fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a7248383604051610a479291906119d3565b60405180910390a250505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614610b7a575f80610aeb60095f8673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f206107a660201b610d6a17610ae0866107bb60201b60201c565b61082860201b60201c565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16915079ffffffffffffffffffffffffffffffffffffffffffffffffffff1691508373ffffffffffffffffffffffffffffffffffffffff167fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a7248383604051610b6f9291906119d3565b60405180910390a250505b5b505050565b5f610b8f610c1d60201b60201c565b905090565b5f80825f018054905090505f8114610bf257610bc4835f01600183610bb99190611ba6565b610c3260201b60201c565b5f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff16610bf4565b5f5b915050919050565b5f80610c11855f018585610c4460201b60201c565b91509150935093915050565b5f610c2d43610fb860201b60201c565b905090565b5f825f528160205f2001905092915050565b5f805f858054905090505f811115610ed0575f610c7387600184610c689190611ba6565b610c3260201b60201c565b6040518060400160405290815f82015f9054906101000a900465ffffffffffff1665ffffffffffff1665ffffffffffff1681526020015f820160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff168152505090508565ffffffffffff16815f015165ffffffffffff161115610d5e576040517f2520601d00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8565ffffffffffff16815f015165ffffffffffff1603610de65784610d9588600185610d8a9190611ba6565b610c3260201b60201c565b5f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff160217905550610ebf565b8660405180604001604052808865ffffffffffff1681526020018779ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505b806020015185935093505050610fb0565b8560405180604001604052808765ffffffffffff1681526020018679ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505f8492509250505b935093915050565b5f65ffffffffffff8016821115611009576030826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401611000929190611c12565b60405180910390fd5b819050919050565b5f604051905090565b5f80fd5b5f80fd5b5f80fd5b5f80fd5b5f601f19601f8301169050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b6110708261102a565b810181811067ffffffffffffffff8211171561108f5761108e61103a565b5b80604052505050565b5f6110a1611011565b90506110ad8282611067565b919050565b5f67ffffffffffffffff8211156110cc576110cb61103a565b5b6110d58261102a565b9050602081019050919050565b8281835e5f83830152505050565b5f6111026110fd846110b2565b611098565b90508281526020810184848401111561111e5761111d611026565b5b6111298482856110e2565b509392505050565b5f82601f83011261114557611144611022565b5b81516111558482602086016110f0565b91505092915050565b5f67ffffffffffffffff8211156111785761117761103a565b5b602082029050602081019050919050565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f6111b68261118d565b9050919050565b6111c6816111ac565b81146111d0575f80fd5b50565b5f815190506111e1816111bd565b92915050565b5f6111f96111f48461115e565b611098565b9050808382526020820190506020840283018581111561121c5761121b611189565b5b835b81811015611245578061123188826111d3565b84526020840193505060208101905061121e565b5050509392505050565b5f82601f83011261126357611262611022565b5b81516112738482602086016111e7565b91505092915050565b5f67ffffffffffffffff8211156112965761129561103a565b5b602082029050602081019050919050565b5f819050919050565b6112b9816112a7565b81146112c3575f80fd5b50565b5f815190506112d4816112b0565b92915050565b5f6112ec6112e78461127c565b611098565b9050808382526020820190506020840283018581111561130f5761130e611189565b5b835b81811015611338578061132488826112c6565b845260208401935050602081019050611311565b5050509392505050565b5f82601f83011261135657611355611022565b5b81516113668482602086016112da565b91505092915050565b5f805f80608085870312156113875761138661101a565b5b5f85015167ffffffffffffffff8111156113a4576113a361101e565b5b6113b087828801611131565b945050602085015167ffffffffffffffff8111156113d1576113d061101e565b5b6113dd87828801611131565b935050604085015167ffffffffffffffff8111156113fe576113fd61101e565b5b61140a8782880161124f565b925050606085015167ffffffffffffffff81111561142b5761142a61101e565b5b61143787828801611342565b91505092959194509250565b5f81519050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602260045260245ffd5b5f600282049050600182168061149157607f821691505b6020821081036114a4576114a361144d565b5b50919050565b5f819050815f5260205f209050919050565b5f6020601f8301049050919050565b5f82821b905092915050565b5f600883026115067fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff826114cb565b61151086836114cb565b95508019841693508086168417925050509392505050565b5f819050919050565b5f61154b611546611541846112a7565b611528565b6112a7565b9050919050565b5f819050919050565b61156483611531565b61157861157082611552565b8484546114d7565b825550505050565b5f90565b61158c611580565b61159781848461155b565b505050565b5b818110156115ba576115af5f82611584565b60018101905061159d565b5050565b601f8211156115ff576115d0816114aa565b6115d9846114bc565b810160208510156115e8578190505b6115fc6115f4856114bc565b83018261159c565b50505b505050565b5f82821c905092915050565b5f61161f5f1984600802611604565b1980831691505092915050565b5f6116378383611610565b9150826002028217905092915050565b61165082611443565b67ffffffffffffffff8111156116695761166861103a565b5b611673825461147a565b61167e8282856115be565b5f60209050601f8311600181146116af575f841561169d578287015190505b6116a7858261162c565b86555061170e565b601f1984166116bd866114aa565b5f5b828110156116e4578489015182556001820191506020850194506020810190506116bf565b8683101561170157848901516116fd601f891682611610565b8355505b6001600288020188555050505b505050505050565b5f82825260208201905092915050565b7f696e697469616c416d6f756e7473206d757374206265206173206d616e7920615f8201527f7320696e697469616c4d656d6265727300000000000000000000000000000000602082015250565b5f611780603083611716565b915061178b82611726565b604082019050919050565b5f6020820190508181035f8301526117ad81611774565b9050919050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52603260045260245ffd5b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f63ffffffff82169050919050565b5f6118278261180e565b915063ffffffff820361183d5761183c6117e1565b5b600182019050919050565b5f819050919050565b61185a81611848565b82525050565b611869816112a7565b82525050565b611878816111ac565b82525050565b5f60a0820190506118915f830188611851565b61189e6020830187611851565b6118ab6040830186611851565b6118b86060830185611860565b6118c5608083018461186f565b9695505050505050565b5f6020820190506118e25f83018461186f565b92915050565b5f6118f282611443565b6118fc8185611716565b935061190c8185602086016110e2565b6119158161102a565b840191505092915050565b5f6020820190508181035f83015261193881846118e8565b905092915050565b5f81519050919050565b5f819050602082019050919050565b5f6119648251611848565b80915050919050565b5f61197782611940565b826119818461194a565b905061198c81611959565b925060208210156119cc576119c77fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff836020036008026114cb565b831692505b5050919050565b5f6040820190506119e65f830185611860565b6119f36020830184611860565b9392505050565b5f611a04826112a7565b9150611a0f836112a7565b9250828201905080821115611a2757611a266117e1565b5b92915050565b5f606082019050611a405f83018661186f565b611a4d6020830185611860565b611a5a6040830184611860565b949350505050565b5f602082019050611a755f830184611860565b92915050565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff82169050919050565b5f611aaa82611a7b565b9150611ab583611a7b565b9250828201905079ffffffffffffffffffffffffffffffffffffffffffffffffffff811115611ae757611ae66117e1565b5b92915050565b5f819050919050565b5f60ff82169050919050565b5f611b1c611b17611b1284611aed565b611528565b611af6565b9050919050565b611b2c81611b02565b82525050565b5f604082019050611b455f830185611b23565b611b526020830184611860565b9392505050565b5f611b6382611a7b565b9150611b6e83611a7b565b9250828203905079ffffffffffffffffffffffffffffffffffffffffffffffffffff811115611ba057611b9f6117e1565b5b92915050565b5f611bb0826112a7565b9150611bbb836112a7565b9250828203905081811115611bd357611bd26117e1565b5b92915050565b5f819050919050565b5f611bfc611bf7611bf284611bd9565b611528565b611af6565b9050919050565b611c0c81611be2565b82525050565b5f604082019050611c255f830185611c03565b611c326020830184611860565b9392505050565b60805160a05160c05160e0516101005161012051610140516137a8611c8a5f395f61137301525f61133801525f61177b01525f61175a01525f610f3201525f610f8801525f610fb101526137a85ff3fe608060405234801561000f575f80fd5b5060043610610156575f3560e01c806370a08231116100c15780639ab24eb01161007a5780639ab24eb014610408578063a9059cbb14610438578063c3cda52014610468578063d505accf14610484578063dd62ed3e146104a0578063f1127ed8146104d057610156565b806370a08231146103185780637ecebe001461034857806384b0196e146103785780638e539e8c1461039c57806391ddadf4146103cc57806395d89b41146103ea57610156565b80633a46b1a8116101135780633a46b1a81461023257806340c10f19146102625780634bf5d7e91461027e578063587cde1e1461029c5780635c19a95c146102cc5780636fcfff45146102e857610156565b806306fdde031461015a578063095ea7b31461017857806318160ddd146101a857806323b872dd146101c6578063313ce567146101f65780633644e51514610214575b5f80fd5b610162610500565b60405161016f9190612acb565b60405180910390f35b610192600480360381019061018d9190612b7c565b610590565b60405161019f9190612bd4565b60405180910390f35b6101b06105b2565b6040516101bd9190612bfc565b60405180910390f35b6101e060048036038101906101db9190612c15565b6105bb565b6040516101ed9190612bd4565b60405180910390f35b6101fe6105e9565b60405161020b9190612c80565b60405180910390f35b61021c6105f1565b6040516102299190612cb1565b60405180910390f35b61024c60048036038101906102479190612b7c565b6105ff565b6040516102599190612bfc565b60405180910390f35b61027c60048036038101906102779190612b7c565b6106d5565b005b6102866106e3565b6040516102939190612acb565b60405180910390f35b6102b660048036038101906102b19190612cca565b610777565b6040516102c39190612d04565b60405180910390f35b6102e660048036038101906102e19190612cca565b6107dc565b005b61030260048036038101906102fd9190612cca565b6107f5565b60405161030f9190612d3b565b60405180910390f35b610332600480360381019061032d9190612cca565b610806565b60405161033f9190612bfc565b60405180910390f35b610362600480360381019061035d9190612cca565b61084b565b60405161036f9190612bfc565b60405180910390f35b61038061085c565b6040516103939796959493929190612e45565b60405180910390f35b6103b660048036038101906103b19190612ec7565b610901565b6040516103c39190612bfc565b60405180910390f35b6103d461099b565b6040516103e19190612f12565b60405180910390f35b6103f26109a9565b6040516103ff9190612acb565b60405180910390f35b610422600480360381019061041d9190612cca565b610a39565b60405161042f9190612bfc565b60405180910390f35b610452600480360381019061044d9190612b7c565b610aa2565b60405161045f9190612bd4565b60405180910390f35b610482600480360381019061047d9190612f7f565b610ac4565b005b61049e60048036038101906104999190613008565b610b89565b005b6104ba60048036038101906104b591906130a5565b610cce565b6040516104c79190612bfc565b60405180910390f35b6104ea60048036038101906104e5919061310d565b610d50565b6040516104f791906131bb565b60405180910390f35b60606003805461050f90613201565b80601f016020809104026020016040519081016040528092919081815260200182805461053b90613201565b80156105865780601f1061055d57610100808354040283529160200191610586565b820191905f5260205f20905b81548152906001019060200180831161056957829003601f168201915b5050505050905090565b5f8061059a610d94565b90506105a7818585610d9b565b600191505092915050565b5f600254905090565b5f806105c5610d94565b90506105d2858285610dad565b6105dd858585610e3f565b60019150509392505050565b5f6012905090565b5f6105fa610f2f565b905090565b5f8061060961099b565b90508065ffffffffffff1683106106595782816040517fecd3f81e000000000000000000000000000000000000000000000000000000008152600401610650929190613231565b60405180910390fd5b6106b061066584610fe5565b60095f8773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2061103e90919063ffffffff16565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff1691505092915050565b6106df828261112b565b5050565b60606106ed6111aa565b65ffffffffffff166106fd61099b565b65ffffffffffff161461073c576040517f6ff0714000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6040518060400160405280601d81526020017f6d6f64653d626c6f636b6e756d6265722666726f6d3d64656661756c74000000815250905090565b5f60085f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b5f6107e5610d94565b90506107f181836111b9565b5050565b5f6107ff826112c9565b9050919050565b5f805f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050919050565b5f6108558261131e565b9050919050565b5f6060805f805f606061086d61132f565b61087561136a565b46305f801b5f67ffffffffffffffff81111561089457610893613258565b5b6040519080825280602002602001820160405280156108c25781602001602082028036833780820191505090505b507f0f00000000000000000000000000000000000000000000000000000000000000959493929190965096509650965096509650965090919293949596565b5f8061090b61099b565b90508065ffffffffffff16831061095b5782816040517fecd3f81e000000000000000000000000000000000000000000000000000000008152600401610952929190613231565b60405180910390fd5b61097761096784610fe5565b600a61103e90919063ffffffff16565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16915050919050565b5f6109a46111aa565b905090565b6060600480546109b890613201565b80601f01602080910402602001604051908101604052809291908181526020018280546109e490613201565b8015610a2f5780601f10610a0657610100808354040283529160200191610a2f565b820191905f5260205f20905b815481529060010190602001808311610a1257829003601f168201915b5050505050905090565b5f610a7f60095f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f206113a5565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff169050919050565b5f80610aac610d94565b9050610ab9818585610e3f565b600191505092915050565b83421115610b0957836040517f4683af0e000000000000000000000000000000000000000000000000000000008152600401610b009190612bfc565b60405180910390fd5b5f610b6a610b627fe48329057bfd03d55e49b547132e39cffd9c1820ad7b9d4c5307691425d15adf898989604051602001610b479493929190613285565b60405160208183030381529060405280519060200120611407565b858585611420565b9050610b76818761144e565b610b8081886111b9565b50505050505050565b83421115610bce57836040517f62791302000000000000000000000000000000000000000000000000000000008152600401610bc59190612bfc565b60405180910390fd5b5f7f6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9888888610bfc8c6114a5565b89604051602001610c12969594939291906132c8565b6040516020818303038152906040528051906020012090505f610c3482611407565b90505f610c4382878787611420565b90508973ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614610cb757808a6040517f4b800e46000000000000000000000000000000000000000000000000000000008152600401610cae929190613327565b60405180910390fd5b610cc28a8a8a610d9b565b50505050505050505050565b5f60015f8473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2054905092915050565b610d58612a1f565b610d6283836114f8565b905092915050565b5f8183610d77919061337b565b905092915050565b5f8183610d8c91906133c8565b905092915050565b5f33905090565b610da88383836001611557565b505050565b5f610db88484610cce565b90507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8114610e395781811015610e2a578281836040517ffb8f41b2000000000000000000000000000000000000000000000000000000008152600401610e2193929190613415565b60405180910390fd5b610e3884848484035f611557565b5b50505050565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603610eaf575f6040517f96c6fd1e000000000000000000000000000000000000000000000000000000008152600401610ea69190612d04565b60405180910390fd5b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1603610f1f575f6040517fec442f05000000000000000000000000000000000000000000000000000000008152600401610f169190612d04565b60405180910390fd5b610f2a838383611726565b505050565b5f7f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff163073ffffffffffffffffffffffffffffffffffffffff16148015610faa57507f000000000000000000000000000000000000000000000000000000000000000046145b15610fd7577f00000000000000000000000000000000000000000000000000000000000000009050610fe2565b610fdf611736565b90505b90565b5f65ffffffffffff8016821115611036576030826040517f6dfcc65000000000000000000000000000000000000000000000000000000000815260040161102d92919061348c565b60405180910390fd5b819050919050565b5f80835f018054905090505f8082905060058311156110bf575f611061846117cb565b8461106c91906134b3565b905061107a875f01826118c1565b5f015f9054906101000a900465ffffffffffff1665ffffffffffff168665ffffffffffff1610156110ad578091506110bd565b6001816110ba91906134e6565b92505b505b5f6110ce875f018785856118d3565b90505f811461111d576110ef875f016001836110ea91906134b3565b6118c1565b5f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff1661111f565b5f5b94505050505092915050565b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160361119b575f6040517fec442f050000000000000000000000000000000000000000000000000000000081526004016111929190612d04565b60405180910390fd5b6111a65f8383611726565b5050565b5f6111b443610fe5565b905090565b5f6111c383610777565b90508160085f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167f3134e8a2e6d97e929a7e54011ea5485d7d196dd5f0ba4d4ef95803e8e3fc257f60405160405180910390a46112c481836112bf86611948565b611959565b505050565b5f61131761131260095f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20611bc9565b611bd8565b9050919050565b5f61132882611c2f565b9050919050565b606061136560057f0000000000000000000000000000000000000000000000000000000000000000611c7590919063ffffffff16565b905090565b60606113a060067f0000000000000000000000000000000000000000000000000000000000000000611c7590919063ffffffff16565b905090565b5f80825f018054905090505f81146113fd576113cf835f016001836113ca91906134b3565b6118c1565b5f0160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff166113ff565b5f5b915050919050565b5f611419611413610f2f565b83611d22565b9050919050565b5f805f8061143088888888611d62565b9250925092506114408282611e49565b829350505050949350505050565b5f611458836114a5565b90508082146114a05782816040517f752d88c0000000000000000000000000000000000000000000000000000000008152600401611497929190613519565b60405180910390fd5b505050565b5f60075f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f815480929190600101919050559050919050565b611500612a1f565b61154f8260095f8673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20611fab90919063ffffffff16565b905092915050565b5f73ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff16036115c7575f6040517fe602df050000000000000000000000000000000000000000000000000000000081526004016115be9190612d04565b60405180910390fd5b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603611637575f6040517f94280d6200000000000000000000000000000000000000000000000000000000815260040161162e9190612d04565b60405180910390fd5b8160015f8673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20819055508015611720578273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040516117179190612bfc565b60405180910390a35b50505050565b61173183838361207a565b505050565b5f7f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f7f00000000000000000000000000000000000000000000000000000000000000007f000000000000000000000000000000000000000000000000000000000000000046306040516020016117b0959493929190613540565b60405160208183030381529060405280519060200120905090565b5f8082036117db575f90506118bc565b5f60016117e784612128565b901c6001901b9050600181848161180157611800613591565b5b048201901c9050600181848161181a57611819613591565b5b048201901c9050600181848161183357611832613591565b5b048201901c9050600181848161184c5761184b613591565b5b048201901c9050600181848161186557611864613591565b5b048201901c9050600181848161187e5761187d613591565b5b048201901c9050600181848161189757611896613591565b5b048201901c90506118b8818285816118b2576118b1613591565b5b046121ff565b9150505b919050565b5f825f528160205f2001905092915050565b5f5b8183101561193d575f6118e88484612217565b90508465ffffffffffff166118fd87836118c1565b5f015f9054906101000a900465ffffffffffff1665ffffffffffff16111561192757809250611937565b60018161193491906134e6565b93505b506118d5565b819050949350505050565b5f61195282610806565b9050919050565b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff161415801561199457505f81115b15611bc4575f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1614611aae575f80611a1f60095f8773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20610d7f611a1a8661223c565b6122a9565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16915079ffffffffffffffffffffffffffffffffffffffffffffffffffff1691508473ffffffffffffffffffffffffffffffffffffffff167fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a7248383604051611aa39291906135be565b60405180910390a250505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614611bc3575f80611b3460095f8673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20610d6a611b2f8661223c565b6122a9565b79ffffffffffffffffffffffffffffffffffffffffffffffffffff16915079ffffffffffffffffffffffffffffffffffffffffffffffffffff1691508373ffffffffffffffffffffffffffffffffffffffff167fdec2bacdd2f05b59de34da9b523dff8be42e5e38e818c82fdb0bae774387a7248383604051611bb89291906135be565b60405180910390a250505b5b505050565b5f815f01805490509050919050565b5f63ffffffff8016821115611c27576020826040517f6dfcc650000000000000000000000000000000000000000000000000000000008152600401611c1e92919061361e565b60405180910390fd5b819050919050565b5f60075f8373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f20549050919050565b606060ff5f1b8314611c9157611c8a836122e8565b9050611d1c565b818054611c9d90613201565b80601f0160208091040260200160405190810160405280929190818152602001828054611cc990613201565b8015611d145780601f10611ceb57610100808354040283529160200191611d14565b820191905f5260205f20905b815481529060010190602001808311611cf757829003601f168201915b505050505090505b92915050565b5f6040517f190100000000000000000000000000000000000000000000000000000000000081528360028201528260228201526042812091505092915050565b5f805f7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0845f1c1115611d9e575f600385925092509250611e3f565b5f6001888888886040515f8152602001604052604051611dc19493929190613645565b6020604051602081039080840390855afa158015611de1573d5f803e3d5ffd5b5050506020604051035190505f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1603611e32575f60015f801b93509350935050611e3f565b805f805f1b935093509350505b9450945094915050565b5f6003811115611e5c57611e5b613688565b5b826003811115611e6f57611e6e613688565b5b0315611fa75760016003811115611e8957611e88613688565b5b826003811115611e9c57611e9b613688565b5b03611ed3576040517ff645eedf00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60026003811115611ee757611ee6613688565b5b826003811115611efa57611ef9613688565b5b03611f3e57805f1c6040517ffce698f7000000000000000000000000000000000000000000000000000000008152600401611f359190612bfc565b60405180910390fd5b600380811115611f5157611f50613688565b5b826003811115611f6457611f63613688565b5b03611fa657806040517fd78bce0c000000000000000000000000000000000000000000000000000000008152600401611f9d9190612cb1565b60405180910390fd5b5b5050565b611fb3612a1f565b825f018263ffffffff1681548110611fce57611fcd6136b5565b5b905f5260205f20016040518060400160405290815f82015f9054906101000a900465ffffffffffff1665ffffffffffff1665ffffffffffff1681526020015f820160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff1681525050905092915050565b61208583838361235a565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603612118575f6120c16105b2565b90505f6120cc612573565b9050808211156121155781816040517f1cb15d2600000000000000000000000000000000000000000000000000000000815260040161210c9291906135be565b60405180910390fd5b50505b612123838383612596565b505050565b5f805f90505f608084901c111561214757608083901c92506080810190505b5f604084901c111561216157604083901c92506040810190505b5f602084901c111561217b57602083901c92506020810190505b5f601084901c111561219557601083901c92506010810190505b5f600884901c11156121af57600883901c92506008810190505b5f600484901c11156121c957600483901c92506004810190505b5f600284901c11156121e357600283901c92506002810190505b5f600184901c11156121f6576001810190505b80915050919050565b5f81831061220d578161220f565b825b905092915050565b5f600282841861222791906136e2565b82841661223491906134e6565b905092915050565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff80168211156122a15760d0826040517f6dfcc65000000000000000000000000000000000000000000000000000000000815260040161229892919061374b565b60405180910390fd5b819050919050565b5f806122dc6122b661099b565b6122cc6122c2886113a5565b868863ffffffff16565b8761264e9092919063ffffffff16565b91509150935093915050565b60605f6122f483612669565b90505f602067ffffffffffffffff81111561231257612311613258565b5b6040519080825280601f01601f1916602001820160405280156123445781602001600182028036833780820191505090505b5090508181528360208201528092505050919050565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16036123aa578060025f82825461239e91906134e6565b92505081905550612478565b5f805f8573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2054905081811015612433578381836040517fe450d38c00000000000000000000000000000000000000000000000000000000815260040161242a93929190613415565b60405180910390fd5b8181035f808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f2081905550505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16036124bf578060025f8282540392505081905550612509565b805f808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020015f205f82825401925050819055505b8173ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef836040516125669190612bfc565b60405180910390a3505050565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff8016905090565b5f73ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff16036125e2576125df600a610d6a6125da8461223c565b6122a9565b50505b5f73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160361262e5761262b600a610d7f6126268461223c565b6122a9565b50505b61264961263a84610777565b61264384610777565b83611959565b505050565b5f8061265d855f0185856126b7565b91509150935093915050565b5f8060ff835f1c169050601f8111156126ae576040517fb3512b0c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b80915050919050565b5f805f858054905090505f811115612937575f6126e0876001846126db91906134b3565b6118c1565b6040518060400160405290815f82015f9054906101000a900465ffffffffffff1665ffffffffffff1665ffffffffffff1681526020015f820160069054906101000a900479ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff1679ffffffffffffffffffffffffffffffffffffffffffffffffffff168152505090508565ffffffffffff16815f015165ffffffffffff1611156127cb576040517f2520601d00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8565ffffffffffff16815f015165ffffffffffff160361284d57846127fc886001856127f791906134b3565b6118c1565b5f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff160217905550612926565b8660405180604001604052808865ffffffffffff1681526020018779ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505b806020015185935093505050612a17565b8560405180604001604052808765ffffffffffff1681526020018679ffffffffffffffffffffffffffffffffffffffffffffffffffff16815250908060018154018082558091505060019003905f5260205f20015f909190919091505f820151815f015f6101000a81548165ffffffffffff021916908365ffffffffffff1602179055506020820151815f0160066101000a81548179ffffffffffffffffffffffffffffffffffffffffffffffffffff021916908379ffffffffffffffffffffffffffffffffffffffffffffffffffff16021790555050505f8492509250505b935093915050565b60405180604001604052805f65ffffffffffff1681526020015f79ffffffffffffffffffffffffffffffffffffffffffffffffffff1681525090565b5f81519050919050565b5f82825260208201905092915050565b8281835e5f83830152505050565b5f601f19601f8301169050919050565b5f612a9d82612a5b565b612aa78185612a65565b9350612ab7818560208601612a75565b612ac081612a83565b840191505092915050565b5f6020820190508181035f830152612ae38184612a93565b905092915050565b5f80fd5b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f612b1882612aef565b9050919050565b612b2881612b0e565b8114612b32575f80fd5b50565b5f81359050612b4381612b1f565b92915050565b5f819050919050565b612b5b81612b49565b8114612b65575f80fd5b50565b5f81359050612b7681612b52565b92915050565b5f8060408385031215612b9257612b91612aeb565b5b5f612b9f85828601612b35565b9250506020612bb085828601612b68565b9150509250929050565b5f8115159050919050565b612bce81612bba565b82525050565b5f602082019050612be75f830184612bc5565b92915050565b612bf681612b49565b82525050565b5f602082019050612c0f5f830184612bed565b92915050565b5f805f60608486031215612c2c57612c2b612aeb565b5b5f612c3986828701612b35565b9350506020612c4a86828701612b35565b9250506040612c5b86828701612b68565b9150509250925092565b5f60ff82169050919050565b612c7a81612c65565b82525050565b5f602082019050612c935f830184612c71565b92915050565b5f819050919050565b612cab81612c99565b82525050565b5f602082019050612cc45f830184612ca2565b92915050565b5f60208284031215612cdf57612cde612aeb565b5b5f612cec84828501612b35565b91505092915050565b612cfe81612b0e565b82525050565b5f602082019050612d175f830184612cf5565b92915050565b5f63ffffffff82169050919050565b612d3581612d1d565b82525050565b5f602082019050612d4e5f830184612d2c565b92915050565b5f7fff0000000000000000000000000000000000000000000000000000000000000082169050919050565b612d8881612d54565b82525050565b5f81519050919050565b5f82825260208201905092915050565b5f819050602082019050919050565b612dc081612b49565b82525050565b5f612dd18383612db7565b60208301905092915050565b5f602082019050919050565b5f612df382612d8e565b612dfd8185612d98565b9350612e0883612da8565b805f5b83811015612e38578151612e1f8882612dc6565b9750612e2a83612ddd565b925050600181019050612e0b565b5085935050505092915050565b5f60e082019050612e585f83018a612d7f565b8181036020830152612e6a8189612a93565b90508181036040830152612e7e8188612a93565b9050612e8d6060830187612bed565b612e9a6080830186612cf5565b612ea760a0830185612ca2565b81810360c0830152612eb98184612de9565b905098975050505050505050565b5f60208284031215612edc57612edb612aeb565b5b5f612ee984828501612b68565b91505092915050565b5f65ffffffffffff82169050919050565b612f0c81612ef2565b82525050565b5f602082019050612f255f830184612f03565b92915050565b612f3481612c65565b8114612f3e575f80fd5b50565b5f81359050612f4f81612f2b565b92915050565b612f5e81612c99565b8114612f68575f80fd5b50565b5f81359050612f7981612f55565b92915050565b5f805f805f8060c08789031215612f9957612f98612aeb565b5b5f612fa689828a01612b35565b9650506020612fb789828a01612b68565b9550506040612fc889828a01612b68565b9450506060612fd989828a01612f41565b9350506080612fea89828a01612f6b565b92505060a0612ffb89828a01612f6b565b9150509295509295509295565b5f805f805f805f60e0888a03121561302357613022612aeb565b5b5f6130308a828b01612b35565b97505060206130418a828b01612b35565b96505060406130528a828b01612b68565b95505060606130638a828b01612b68565b94505060806130748a828b01612f41565b93505060a06130858a828b01612f6b565b92505060c06130968a828b01612f6b565b91505092959891949750929550565b5f80604083850312156130bb576130ba612aeb565b5b5f6130c885828601612b35565b92505060206130d985828601612b35565b9150509250929050565b6130ec81612d1d565b81146130f6575f80fd5b50565b5f81359050613107816130e3565b92915050565b5f806040838503121561312357613122612aeb565b5b5f61313085828601612b35565b9250506020613141858286016130f9565b9150509250929050565b61315481612ef2565b82525050565b5f79ffffffffffffffffffffffffffffffffffffffffffffffffffff82169050919050565b6131888161315a565b82525050565b604082015f8201516131a25f85018261314b565b5060208201516131b5602085018261317f565b50505050565b5f6040820190506131ce5f83018461318e565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602260045260245ffd5b5f600282049050600182168061321857607f821691505b60208210810361322b5761322a6131d4565b5b50919050565b5f6040820190506132445f830185612bed565b6132516020830184612f03565b9392505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b5f6080820190506132985f830187612ca2565b6132a56020830186612cf5565b6132b26040830185612bed565b6132bf6060830184612bed565b95945050505050565b5f60c0820190506132db5f830189612ca2565b6132e86020830188612cf5565b6132f56040830187612cf5565b6133026060830186612bed565b61330f6080830185612bed565b61331c60a0830184612bed565b979650505050505050565b5f60408201905061333a5f830185612cf5565b6133476020830184612cf5565b9392505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f6133858261315a565b91506133908361315a565b9250828201905079ffffffffffffffffffffffffffffffffffffffffffffffffffff8111156133c2576133c161334e565b5b92915050565b5f6133d28261315a565b91506133dd8361315a565b9250828203905079ffffffffffffffffffffffffffffffffffffffffffffffffffff81111561340f5761340e61334e565b5b92915050565b5f6060820190506134285f830186612cf5565b6134356020830185612bed565b6134426040830184612bed565b949350505050565b5f819050919050565b5f819050919050565b5f61347661347161346c8461344a565b613453565b612c65565b9050919050565b6134868161345c565b82525050565b5f60408201905061349f5f83018561347d565b6134ac6020830184612bed565b9392505050565b5f6134bd82612b49565b91506134c883612b49565b92508282039050818111156134e0576134df61334e565b5b92915050565b5f6134f082612b49565b91506134fb83612b49565b92508282019050808211156135135761351261334e565b5b92915050565b5f60408201905061352c5f830185612cf5565b6135396020830184612bed565b9392505050565b5f60a0820190506135535f830188612ca2565b6135606020830187612ca2565b61356d6040830186612ca2565b61357a6060830185612bed565b6135876080830184612cf5565b9695505050505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601260045260245ffd5b5f6040820190506135d15f830185612bed565b6135de6020830184612bed565b9392505050565b5f819050919050565b5f6136086136036135fe846135e5565b613453565b612c65565b9050919050565b613618816135ee565b82525050565b5f6040820190506136315f83018561360f565b61363e6020830184612bed565b9392505050565b5f6080820190506136585f830187612ca2565b6136656020830186612c71565b6136726040830185612ca2565b61367f6060830184612ca2565b95945050505050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52602160045260245ffd5b7f4e487b71000000000000000000000000000000000000000000000000000000005f52603260045260245ffd5b5f6136ec82612b49565b91506136f783612b49565b92508261370757613706613591565b5b828204905092915050565b5f819050919050565b5f61373561373061372b84613712565b613453565b612c65565b9050919050565b6137458161371b565b82525050565b5f60408201905061375e5f83018561373c565b61376b6020830184612bed565b939250505056fea2646970667358221220abde84bc2c44d2f2ffa7568fe489ea81e4872b93df803ebeb335f8b2c53ca3da64736f6c634300081a0033";

String daoAbiGlobal = '''
[
	{
		"inputs": [
			{
				"internalType": "contract IVotes",
				"name": "_token",
				"type": "address"
			},
			{
				"internalType": "contract TimelockController",
				"name": "_timelock",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "CheckpointUnorderedInsertion",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "FailedInnerCall",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "voter",
				"type": "address"
			}
		],
		"name": "GovernorAlreadyCastVote",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "GovernorAlreadyQueuedProposal",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "GovernorDisabledDeposit",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "proposer",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "votes",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "threshold",
				"type": "uint256"
			}
		],
		"name": "GovernorInsufficientProposerVotes",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "targets",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "calldatas",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "values",
				"type": "uint256"
			}
		],
		"name": "GovernorInvalidProposalLength",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "quorumNumerator",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "quorumDenominator",
				"type": "uint256"
			}
		],
		"name": "GovernorInvalidQuorumFraction",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "voter",
				"type": "address"
			}
		],
		"name": "GovernorInvalidSignature",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "GovernorInvalidVoteType",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "votingPeriod",
				"type": "uint256"
			}
		],
		"name": "GovernorInvalidVotingPeriod",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "GovernorNonexistentProposal",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "GovernorNotQueuedProposal",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "GovernorOnlyExecutor",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "GovernorOnlyProposer",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "GovernorQueueNotImplemented",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "proposer",
				"type": "address"
			}
		],
		"name": "GovernorRestrictedProposer",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "enum IGovernor.ProposalState",
				"name": "current",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "expectedStates",
				"type": "bytes32"
			}
		],
		"name": "GovernorUnexpectedProposalState",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "currentNonce",
				"type": "uint256"
			}
		],
		"name": "InvalidAccountNonce",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "InvalidShortString",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "QueueEmpty",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "QueueFull",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint8",
				"name": "bits",
				"type": "uint8"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "SafeCastOverflowedUintDowncast",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "str",
				"type": "string"
			}
		],
		"name": "StringTooLong",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "EIP712DomainChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "ProposalCanceled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "proposer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"indexed": false,
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"indexed": false,
				"internalType": "string[]",
				"name": "signatures",
				"type": "string[]"
			},
			{
				"indexed": false,
				"internalType": "bytes[]",
				"name": "calldatas",
				"type": "bytes[]"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "voteStart",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "voteEnd",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "description",
				"type": "string"
			}
		],
		"name": "ProposalCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "ProposalExecuted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "etaSeconds",
				"type": "uint256"
			}
		],
		"name": "ProposalQueued",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "oldProposalThreshold",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newProposalThreshold",
				"type": "uint256"
			}
		],
		"name": "ProposalThresholdSet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "oldQuorumNumerator",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newQuorumNumerator",
				"type": "uint256"
			}
		],
		"name": "QuorumNumeratorUpdated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "oldTimelock",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "newTimelock",
				"type": "address"
			}
		],
		"name": "TimelockChange",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "voter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "weight",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "reason",
				"type": "string"
			}
		],
		"name": "VoteCast",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "voter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "weight",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "reason",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "bytes",
				"name": "params",
				"type": "bytes"
			}
		],
		"name": "VoteCastWithParams",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "oldVotingDelay",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newVotingDelay",
				"type": "uint256"
			}
		],
		"name": "VotingDelaySet",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "oldVotingPeriod",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newVotingPeriod",
				"type": "uint256"
			}
		],
		"name": "VotingPeriodSet",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "BALLOT_TYPEHASH",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "CLOCK_MODE",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "COUNTING_MODE",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "EXTENDED_BALLOT_TYPEHASH",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "calldatas",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "descriptionHash",
				"type": "bytes32"
			}
		],
		"name": "cancel",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			}
		],
		"name": "castVote",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			},
			{
				"internalType": "address",
				"name": "voter",
				"type": "address"
			},
			{
				"internalType": "bytes",
				"name": "signature",
				"type": "bytes"
			}
		],
		"name": "castVoteBySig",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			},
			{
				"internalType": "string",
				"name": "reason",
				"type": "string"
			}
		],
		"name": "castVoteWithReason",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			},
			{
				"internalType": "string",
				"name": "reason",
				"type": "string"
			},
			{
				"internalType": "bytes",
				"name": "params",
				"type": "bytes"
			}
		],
		"name": "castVoteWithReasonAndParams",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "support",
				"type": "uint8"
			},
			{
				"internalType": "address",
				"name": "voter",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "reason",
				"type": "string"
			},
			{
				"internalType": "bytes",
				"name": "params",
				"type": "bytes"
			},
			{
				"internalType": "bytes",
				"name": "signature",
				"type": "bytes"
			}
		],
		"name": "castVoteWithReasonAndParamsBySig",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "clock",
		"outputs": [
			{
				"internalType": "uint48",
				"name": "",
				"type": "uint48"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "eip712Domain",
		"outputs": [
			{
				"internalType": "bytes1",
				"name": "fields",
				"type": "bytes1"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "version",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "chainId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "verifyingContract",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			},
			{
				"internalType": "uint256[]",
				"name": "extensions",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "calldatas",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "descriptionHash",
				"type": "bytes32"
			}
		],
		"name": "execute",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			}
		],
		"name": "getVotes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "params",
				"type": "bytes"
			}
		],
		"name": "getVotesWithParams",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "hasVoted",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "calldatas",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "descriptionHash",
				"type": "bytes32"
			}
		],
		"name": "hashProposal",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "nonces",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC1155BatchReceived",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC1155Received",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC721Received",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "proposalDeadline",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "proposalEta",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "proposalNeedsQueuing",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "proposalProposer",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "proposalSnapshot",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "proposalThreshold",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "proposalVotes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "againstVotes",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "forVotes",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "abstainVotes",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "calldatas",
				"type": "bytes[]"
			},
			{
				"internalType": "string",
				"name": "description",
				"type": "string"
			}
		],
		"name": "propose",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "calldatas",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "descriptionHash",
				"type": "bytes32"
			}
		],
		"name": "queue",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "blockNumber",
				"type": "uint256"
			}
		],
		"name": "quorum",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "quorumDenominator",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			}
		],
		"name": "quorumNumerator",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "quorumNumerator",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "target",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			}
		],
		"name": "relay",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "newProposalThreshold",
				"type": "uint256"
			}
		],
		"name": "setProposalThreshold",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint48",
				"name": "newVotingDelay",
				"type": "uint48"
			}
		],
		"name": "setVotingDelay",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint32",
				"name": "newVotingPeriod",
				"type": "uint32"
			}
		],
		"name": "setVotingPeriod",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposalId",
				"type": "uint256"
			}
		],
		"name": "state",
		"outputs": [
			{
				"internalType": "enum IGovernor.ProposalState",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes4",
				"name": "interfaceId",
				"type": "bytes4"
			}
		],
		"name": "supportsInterface",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "timelock",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "token",
		"outputs": [
			{
				"internalType": "contract IERC5805",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "newQuorumNumerator",
				"type": "uint256"
			}
		],
		"name": "updateQuorumNumerator",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "contract TimelockController",
				"name": "newTimelock",
				"type": "address"
			}
		],
		"name": "updateTimelock",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "version",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "votingDelay",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "votingPeriod",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"stateMutability": "payable",
		"type": "receive"
	}
]
''';

String tokenAbiGlobal = '''
[
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"internalType": "address[]",
				"name": "initialMembers",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "initialAmounts",
				"type": "uint256[]"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "CheckpointUnorderedInsertion",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "ECDSAInvalidSignature",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "length",
				"type": "uint256"
			}
		],
		"name": "ECDSAInvalidSignatureLength",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "s",
				"type": "bytes32"
			}
		],
		"name": "ECDSAInvalidSignatureS",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "increasedSupply",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "cap",
				"type": "uint256"
			}
		],
		"name": "ERC20ExceededSafeSupply",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "allowance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientAllowance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "balance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "needed",
				"type": "uint256"
			}
		],
		"name": "ERC20InsufficientBalance",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "approver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidApprover",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			}
		],
		"name": "ERC20InvalidReceiver",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "ERC20InvalidSpender",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "deadline",
				"type": "uint256"
			}
		],
		"name": "ERC2612ExpiredSignature",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "signer",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "ERC2612InvalidSigner",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			},
			{
				"internalType": "uint48",
				"name": "clock",
				"type": "uint48"
			}
		],
		"name": "ERC5805FutureLookup",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "ERC6372InconsistentClock",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "currentNonce",
				"type": "uint256"
			}
		],
		"name": "InvalidAccountNonce",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "InvalidShortString",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint8",
				"name": "bits",
				"type": "uint8"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "SafeCastOverflowedUintDowncast",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "str",
				"type": "string"
			}
		],
		"name": "StringTooLong",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "expiry",
				"type": "uint256"
			}
		],
		"name": "VotesExpiredSignature",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "delegator",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "fromDelegate",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "toDelegate",
				"type": "address"
			}
		],
		"name": "DelegateChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "delegate",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "previousVotes",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newVotes",
				"type": "uint256"
			}
		],
		"name": "DelegateVotesChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "EIP712DomainChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "CLOCK_MODE",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "DOMAIN_SEPARATOR",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint32",
				"name": "pos",
				"type": "uint32"
			}
		],
		"name": "checkpoints",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint48",
						"name": "_key",
						"type": "uint48"
					},
					{
						"internalType": "uint208",
						"name": "_value",
						"type": "uint208"
					}
				],
				"internalType": "struct Checkpoints.Checkpoint208",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "clock",
		"outputs": [
			{
				"internalType": "uint48",
				"name": "",
				"type": "uint48"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "delegatee",
				"type": "address"
			}
		],
		"name": "delegate",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "delegatee",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "nonce",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "expiry",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "v",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "r",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "s",
				"type": "bytes32"
			}
		],
		"name": "delegateBySig",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "delegates",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "eip712Domain",
		"outputs": [
			{
				"internalType": "bytes1",
				"name": "fields",
				"type": "bytes1"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "version",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "chainId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "verifyingContract",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			},
			{
				"internalType": "uint256[]",
				"name": "extensions",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			}
		],
		"name": "getPastTotalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "timepoint",
				"type": "uint256"
			}
		],
		"name": "getPastVotes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "getVotes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "mint",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "nonces",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "numCheckpoints",
		"outputs": [
			{
				"internalType": "uint32",
				"name": "",
				"type": "uint32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "deadline",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "v",
				"type": "uint8"
			},
			{
				"internalType": "bytes32",
				"name": "r",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "s",
				"type": "bytes32"
			}
		],
		"name": "permit",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
''';

String timelockAbiGlobal = '''
[
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "minDelay",
				"type": "uint256"
			},
			{
				"internalType": "address[]",
				"name": "proposers",
				"type": "address[]"
			},
			{
				"internalType": "address[]",
				"name": "executors",
				"type": "address[]"
			},
			{
				"internalType": "address",
				"name": "admin",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "AccessControlBadConfirmation",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "neededRole",
				"type": "bytes32"
			}
		],
		"name": "AccessControlUnauthorizedAccount",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "FailedInnerCall",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "delay",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "minDelay",
				"type": "uint256"
			}
		],
		"name": "TimelockInsufficientDelay",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "targets",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "payloads",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "values",
				"type": "uint256"
			}
		],
		"name": "TimelockInvalidOperationLength",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "caller",
				"type": "address"
			}
		],
		"name": "TimelockUnauthorizedCaller",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "predecessorId",
				"type": "bytes32"
			}
		],
		"name": "TimelockUnexecutedPredecessor",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "operationId",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "expectedStates",
				"type": "bytes32"
			}
		],
		"name": "TimelockUnexpectedOperationState",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "target",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			}
		],
		"name": "CallExecuted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			},
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			}
		],
		"name": "CallSalt",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "target",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			},
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "delay",
				"type": "uint256"
			}
		],
		"name": "CallScheduled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "Cancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "oldDuration",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newDuration",
				"type": "uint256"
			}
		],
		"name": "MinDelayChange",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "previousAdminRole",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "newAdminRole",
				"type": "bytes32"
			}
		],
		"name": "RoleAdminChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "RoleGranted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "RoleRevoked",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "CANCELLER_ROLE",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "DEFAULT_ADMIN_ROLE",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "EXECUTOR_ROLE",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "PROPOSER_ROLE",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "cancel",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "target",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "payload",
				"type": "bytes"
			},
			{
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			}
		],
		"name": "execute",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "payloads",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			}
		],
		"name": "executeBatch",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getMinDelay",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "getOperationState",
		"outputs": [
			{
				"internalType": "enum TimelockController.OperationState",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			}
		],
		"name": "getRoleAdmin",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "getTimestamp",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "grantRole",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "hasRole",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "target",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			},
			{
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			}
		],
		"name": "hashOperation",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "payloads",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			}
		],
		"name": "hashOperationBatch",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "isOperation",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "isOperationDone",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "isOperationPending",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "isOperationReady",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC1155BatchReceived",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC1155Received",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC721Received",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"internalType": "address",
				"name": "callerConfirmation",
				"type": "address"
			}
		],
		"name": "renounceRole",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "role",
				"type": "bytes32"
			},
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "revokeRole",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "target",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			},
			{
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "delay",
				"type": "uint256"
			}
		],
		"name": "schedule",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "targets",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "values",
				"type": "uint256[]"
			},
			{
				"internalType": "bytes[]",
				"name": "payloads",
				"type": "bytes[]"
			},
			{
				"internalType": "bytes32",
				"name": "predecessor",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "salt",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "delay",
				"type": "uint256"
			}
		],
		"name": "scheduleBatch",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes4",
				"name": "interfaceId",
				"type": "bytes4"
			}
		],
		"name": "supportsInterface",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "newDelay",
				"type": "uint256"
			}
		],
		"name": "updateDelay",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"stateMutability": "payable",
		"type": "receive"
	}
]
''';

String registryAbi = '''[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_wrapper",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "string[]",
				"name": "newKeys",
				"type": "string[]"
			},
			{
				"internalType": "string[]",
				"name": "values",
				"type": "string[]"
			}
		],
		"name": "batchEditRegistry",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "key",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "value",
				"type": "string"
			}
		],
		"name": "editRegistry",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllKeys",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllValues",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "key",
				"type": "string"
			}
		],
		"name": "getRegistryValue",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "wrapper",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]''';
