import 'package:web3dart/contracts.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

final editRegistryDef = ContractFunction(
  "editRegistry",
  [
    FunctionParameter("key", StringType()),
    FunctionParameter("Value", StringType()),
  ],
);

final mintGovTokensDef = ContractFunction(
  "mint",
  [
    FunctionParameter("to", AddressType()),
    FunctionParameter("amount", UintType()),
  ],
);

final burnGovTokensDef = ContractFunction(
  "burn",
  [
    FunctionParameter("from", AddressType()),
    FunctionParameter("amount", UintType()),
  ],
);
