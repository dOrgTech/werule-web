import 'dart:math';
import 'package:Homebase/entities/definitions.dart';
import 'package:Homebase/widgets/initiative.dart';
import 'package:Homebase/widgets/newProposal.dart';
import 'package:Homebase/widgets/registryPropo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import '../entities/contractFunctions.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';

class GovernanceTokenOperationsWidget extends StatefulWidget {
  Org org;
  State proposalsState;
  InitiativeState initiativeState;
  Proposal p;
  bool isSetinfo = false;
  int stage = 0;
  GovernanceTokenOperationsWidget(
      {required this.initiativeState,
      required this.org,
      required this.p,
      required this.proposalsState});

  @override
  _GovernanceTokenOperationsWidgetState createState() =>
      _GovernanceTokenOperationsWidgetState();
}

class _GovernanceTokenOperationsWidgetState
    extends State<GovernanceTokenOperationsWidget> {
  String? _selectedOperation;
  bool _isFormValid = false;

  // Controllers for input fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _selectOperation(String operation) {
    setState(() {
      _selectedOperation = operation;
      _isFormValid = false;
      // _addressController.clear();
    });
  }

  void doneSettingInfo() {
    setState(() {
      widget.isSetinfo = false;
    });
  }

  bool _isValidAddress(String address) {
    return address.startsWith("0x") && address.length == 42;
  }

  void _validateForm() {
    // setState(() {
    //   _isFormValid = _isValidAddress(_addressController.text) &&
    //       _amountController.text.isNotEmpty &&
    //       double.tryParse(_amountController.text) != null;
    // });
    runLogic();
  }

  Widget _buildOperationSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildOperationButton("Mint", Icons.add_circle),
        const SizedBox(height: 30),
        _buildOperationButton("Burn", Icons.remove_circle),
      ],
    );
  }

  Widget _buildOperationButton(String title, IconData icon) {
    return SizedBox(
      width: 250,
      height: 130,
      child: ElevatedButton(
        onPressed: () => _selectOperation(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 91, 91, 91),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMintView() {
    return _buildOperationView("Mint", "Mint tokens to a specified address.");
  }

  Widget _buildBurnView() {
    return _buildOperationView("Burn", "Burn tokens from a specified address.");
  }

  Widget _buildOperationView(String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 400,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
            hintText: "e.g., 0x1234567890abcdef...",
          ),
          onChanged: (_) => _validateForm(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9x]')),
          ],
        ),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _validateForm(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationViewContent() {
    switch (_selectedOperation) {
      case "Mint":
        return _buildMintView();
      case "Burn":
        return _buildBurnView();
      default:
        return _buildOperationSelection();
    }
  }

  runLogic() async {
    String address = _addressController.text ?? "";
    EthereumAddress adresa = EthereumAddress.fromHex(address);
    widget.p.values = ["0"];
    widget.initiativeState.widget.p.values = ["0"];
    widget.p.targets = [widget.p.org.govTokenAddress!];
    widget.initiativeState.widget.p.targets = [widget.p.org.govTokenAddress!];
    double amount = double.parse(_amountController.text);
    BigInt number = BigInt.from(amount * pow(10, widget.p.org.decimals!));
    List params = [adresa, number];
    String calldata0;
    if (_selectedOperation == "Mint") {
      print("we selected mint");
      widget.p.type = "Mint " + widget.p.org.symbol!;
      widget.initiativeState.widget.p.type = "Mint " + widget.p.org.symbol!;
      calldata0 = getCalldata(mintGovTokensDef, params);
    } else {
      print("we selected burn");
      widget.p.type = "Burn " + widget.p.org.symbol!;
      widget.initiativeState.widget.p.type = "Burn " + widget.p.org.symbol!;
      calldata0 = getCalldata(burnGovTokensDef, params);
    }
    widget.p.callDatas = [calldata0];
    widget.initiativeState.widget.p.callDatas = [calldata0];
  }

  @override
  void initState() {
    widget.initiativeState.widget.p.type = "mint";
    widget.p.values = ["0"];
    widget.initiativeState.widget.p.values = ["0"];
    widget.p.targets = [widget.org.govTokenAddress!];
    widget.initiativeState.widget.p.targets = [widget.org.govTokenAddress!];
    _amountController.text = "0";
    _addressController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
    super.initState();
  }

  void _resetToInitialView() {
    setState(() {
      _selectedOperation = null;
      _isFormValid = false;
      _addressController.clear();
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.stage == -1
        ? const AwaitingConfirmation()
        : widget.isSetinfo
            ? NewProposal(p: widget.p, next: doneSettingInfo)
            : Container(
                width: 600,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildOperationViewContent(),
                        ),
                      ),
                    ),
                    // Container(
                    //   height: 50,
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   margin: const EdgeInsets.only(bottom: 50),
                    //   child: _selectedOperation != null
                    //       ? Center(
                    //           child: SubmitButton(
                    //               submit: _isFormValid
                    //                   ? () async {
                    //                       String address =
                    //                           _addressController.text;
                    //                       EthereumAddress adresa =
                    //                           EthereumAddress.fromHex(address);
                    //                       widget.p.values = ["0"];
                    //                       widget.p.targets = [
                    //                         widget.p.org.govTokenAddress!
                    //                       ];
                    //                       double amount = double.parse(
                    //                           _amountController.text);
                    //                       BigInt number = BigInt.from(amount *
                    //                           pow(10, widget.p.org.decimals!));
                    //                       List params = [adresa, number];
                    //                       String calldata0;
                    //                       if (_selectedOperation == "Mint") {
                    //                         print("we selected mint");
                    //                         widget.p.type =
                    //                             "Mint " + widget.p.org.symbol!;
                    //                         calldata0 = getCalldata(
                    //                             mintGovTokensDef, params);
                    //                       } else {
                    //                         print("we selected burn");
                    //                         widget.p.type =
                    //                             "Burn " + widget.p.org.symbol!;
                    //                         calldata0 = getCalldata(
                    //                             burnGovTokensDef, params);
                    //                       }
                    //                       widget.p.callDatas = [calldata0];
                    //                       widget.p.statusHistory.addAll(
                    //                           {"pending": DateTime.now()});
                    //                       setState(() {
                    //                         widget.stage = -1;
                    //                       });
                    //                       try {
                    //                         String cevine =
                    //                             await propose(widget.p);
                    //                         if (cevine.contains("not ok")) {
                    //                           ScaffoldMessenger.of(context)
                    //                               .showSnackBar(const SnackBar(
                    //                                   duration:
                    //                                       Duration(seconds: 1),
                    //                                   content: Center(
                    //                                       child: SizedBox(
                    //                                           height: 70,
                    //                                           child: Center(
                    //                                             child: Text(
                    //                                               "Error submitting proposal",
                    //                                               style: TextStyle(
                    //                                                   fontSize:
                    //                                                       24,
                    //                                                   color: Colors
                    //                                                       .red),
                    //                                             ),
                    //                                           )))));
                    //                           Navigator.of(context).pop();
                    //                           return;
                    //                         }
                    //                         widget.p.status = "pending";
                    //                         Navigator.of(context).pop();
                    //                         ScaffoldMessenger.of(context)
                    //                             .showSnackBar(const SnackBar(
                    //                                 duration:
                    //                                     Duration(seconds: 1),
                    //                                 content: Center(
                    //                                     child: SizedBox(
                    //                                         height: 70,
                    //                                         child: Center(
                    //                                           child: Text(
                    //                                             "Proposal submitted",
                    //                                             style: TextStyle(
                    //                                                 fontSize:
                    //                                                     24),
                    //                                           ),
                    //                                         )))));
                    //                       } catch (e) {
                    //                         Navigator.of(context).pop();
                    //                         ScaffoldMessenger.of(context)
                    //                             .showSnackBar(const SnackBar(
                    //                                 duration:
                    //                                     Duration(seconds: 1),
                    //                                 content: Center(
                    //                                     child: SizedBox(
                    //                                         height: 70,
                    //                                         child: Center(
                    //                                           child: Text(
                    //                                             "Error submitting proposal",
                    //                                             style: TextStyle(
                    //                                                 fontSize:
                    //                                                     24,
                    //                                                 color: Colors
                    //                                                     .red),
                    //                                           ),
                    //                                         )))));
                    //                       }
                    //                     }
                    //                   : null,
                    //               isSubmitEnabled: _isFormValid))
                    //       : null,
                    // ),
                  ],
                ),
              );
  }
}
