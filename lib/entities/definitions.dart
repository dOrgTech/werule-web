import 'package:web3dart/contracts.dart';

final editRegistryDef = ContractFunction(
  "editRegistry",
  [
    FunctionParameter("key", StringType()),
    FunctionParameter("Value", StringType()),
  ],
);
