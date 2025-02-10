import 'package:web3dart/contracts.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

const editRegistryDef = ContractFunction(
  "editRegistry",
  [
    FunctionParameter("key", StringType()),
    FunctionParameter("Value", StringType()),
  ],
);

const mintGovTokensDef = ContractFunction(
  "mint",
  [
    FunctionParameter("to", AddressType()),
    FunctionParameter("amount", UintType()),
  ],
);

const burnGovTokensDef = ContractFunction(
  "burn",
  [
    FunctionParameter("from", AddressType()),
    FunctionParameter("amount", UintType()),
  ],
);

const transferNativeDef = ContractFunction(
  "transferETH",
  [
    FunctionParameter("to", AddressType()),
    FunctionParameter("amount", UintType()),
  ],
);

const transferErc20Def = ContractFunction(
  "transferERC20",
  [
    FunctionParameter("token", AddressType()),
    FunctionParameter("to", AddressType()),
    FunctionParameter("amount", UintType()),
  ],
);

const transferERC721Def = ContractFunction(
  "transferERC20",
  [
    FunctionParameter("token", AddressType()),
    FunctionParameter("to", AddressType()),
    FunctionParameter("tokenId", UintType()),
  ],
);

const changeQuorumDef = ContractFunction(
  "updateQuorumNumerator",
  [
    FunctionParameter("newQuorumNumerator", UintType()),
  ],
);

const changeVotingDelayDef = ContractFunction(
  "setVotingDelay",
  [
    FunctionParameter("newVotingDelay", UintType(length: 48)),
  ],
);

const changeVotingPeriodDef = ContractFunction(
  "setVotingPeriod",
  [
    FunctionParameter("newVotingPeriod", UintType(length: 32)),
  ],
);

const changeProposalThresholdDef = ContractFunction(
  "setProposalThreshold",
  [
    FunctionParameter("newProposalThreshold", UintType()),
  ],
);
