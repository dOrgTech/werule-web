// ignore_for_file: avoid_print

import 'package:Homebase/entities/definitions.dart';
import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/widgets/newDebate.dart';
import 'package:Homebase/widgets/newProposal.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import '../entities/org.dart';
import '../entities/token.dart';
import '../entities/contractFunctions.dart';
import 'initiative.dart';

String displayTokenValue(String tokenValueStr, int decimals) {
  double tokenValue = double.parse(tokenValueStr) / pow(10, decimals);
  if (tokenValue == tokenValue.floorToDouble()) {
    return tokenValue
        .toStringAsFixed(0); // Display whole number if no decimals are needed
  }
  return tokenValue
      .toStringAsFixed(2); // Otherwise, show up to 3 decimal places
}

class TransferWidget extends StatefulWidget {
  int stage = 1;
  InitiativeState initiativeState;
  Map<Token, String> treasury = {};
  Org org;
  State proposalsState;
  Proposal p;
  TransferWidget(
      {super.key, required this.initiativeState,
      required this.org,
      required this.p,
      required this.proposalsState}) {
    treasury = org.treasury;
  }

  @override
  _TransferWidgetState createState() => _TransferWidgetState();
}

class _TransferWidgetState extends State<TransferWidget> {
  Map<String, Map<String, double>> assetData = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.p.type = "transfer";
    widget.initiativeState.widget.p.type = "transfer";
  }

  bool isSubmitEnabled = false;
  List<Map<String, dynamic>> transactions = [
    {
      'token': null,
      'recipient': '',
      'amount': '',
      'recipientError': '',
      'amountError': ''
    }
  ];

  final ScrollController _scrollController = ScrollController();

  // Function to validate the recipient address
  bool isValidEvmAddress(String address) {
    return address.length == 42 && address.startsWith('0x');
  }

  // Function to validate the amount
  bool isValidAmount(String value, Token token) {
    if (value.isEmpty) return false;
    try {
      double amount = double.parse(value);
      String tokenValueStr = widget.treasury[token] ?? "0";
      double tokenValue =
          double.parse(tokenValueStr) / pow(10, token.decimals!);
      return amount > 0 && amount <= tokenValue;
    } catch (e) {
      return false;
    }
  }

  // Display the available token value, formatted to 3 decimal places if necessary
  String displayTokenValue(String tokenValueStr, int decimals) {
    double tokenValue = double.parse(tokenValueStr) / pow(10, decimals);
    if (tokenValue == tokenValue.floorToDouble()) {
      return tokenValue
          .toStringAsFixed(0); // Display whole number if no decimals are needed
    }
    return tokenValue
        .toStringAsFixed(2); // Otherwise, show up to 3 decimal places
  }

  // Function to validate all transactions and enable/disable the submit button
  void validateTransactions() {
    bool isValid = true;
    for (var tx in transactions) {
      // Validate recipient address
      if (!isValidEvmAddress(tx['recipient'])) {
        tx['recipientError'] = 'Invalid EVM-compatible address';
        isValid = false;
      } else {
        tx['recipientError'] = '';
      }

      // Validate amount
      if (tx['token'] != null && !isValidAmount(tx['amount'], tx['token'])) {
        tx['amountError'] = 'Invalid amount';
        isValid = false;
      } else {
        tx['amountError'] = '';
      }
    }

    setState(() {
      isSubmitEnabled = isValid;
    });
    submitTransactions();
  }

  // Add a new transaction set
  void addTransaction() {
    setState(() {
      transactions.add({
        'token': null,
        'recipient': '',
        'amount': '',
        'recipientError': '',
        'amountError': ''
      });
      validateTransactions();
    });
  }

  // Remove a transaction
  void removeTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
      validateTransactions(); // Revalidate after removing a transaction
    });
  }

  void submitTransactions() {
    widget.p.callDatas = [];
    for (var tx in transactions) {
      try {
        print("making these here transactions");
        List params = [];
        if (tx['token'].address!.toString().contains("native")) {
          print("we got so myuch native ${tx['amount']}");
          double txamount = double.parse(tx['amount'].toString());
          final BigInt weiAmount = BigInt.from(txamount * 1e18);
          print("we createdbg");
          params = [EthereumAddress.fromHex(tx['recipient']), weiAmount];
          print("getting calldata");
          widget.p.callDatas.add(getCalldata(transferNativeDef, params));
          widget.initiativeState.widget.p.callDatas
              .add(getCalldata(transferNativeDef, params));
          print("got it");
        } else if (tx['token']
            .address!
            .toString()
            .toLowerCase()
            .contains("erc20")) {
          params = [
            (tx['token'] as Token).address!,
            tx['recipient'],
            tx['amount'],
          ];
          widget.p.callDatas.add(getCalldata(transferErc20Def, params));
          widget.initiativeState.widget.p.callDatas
              .add(getCalldata(transferErc20Def, params));
        } else {}
        widget.p.targets.add(widget.org.registryAddress!);
        widget.initiativeState.widget.p.targets
            .add(widget.org.registryAddress!);
        widget.p.values.add("0");
        widget.initiativeState.widget.p.values.add("0");
      } catch (e) {
        print("error here $e");
      }
    }

    widget.initiativeState.widget.p.type = "transfer";
    print("calldatas ${widget.p.callDatas}");

    // widget.p.createdAt = DateTime.now();
    // widget.p.statusHistory.addAll({"pending": DateTime.now()});

    //   setState(() {
    //     widget.stage = -1;
    //   });
    //   try {
    //     print("before sending the transaction");
    //     String cevine = await propose(widget.p);
    //     if (cevine.contains("not ok")) {
    //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //           duration: Duration(seconds: 1),
    //           content: Center(
    //               child: SizedBox(
    //                   height: 70,
    //                   child: Center(
    //                     child: Text(
    //                       "Error submitting proposal",
    //                       style: TextStyle(
    //                           fontSize: 24,
    //                           color: Color.fromARGB(255, 67, 18, 14)),
    //                     ),
    //                   )))));
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //           duration: Duration(seconds: 1),
    //           content: Center(
    //               child: SizedBox(
    //                   height: 70,
    //                   child: Center(
    //                     child: Text(
    //                       "Proposal submitted",
    //                       style: TextStyle(fontSize: 24),
    //                     ),
    //                   )))));
    //     }
    //   } catch (e) {
    //     print("some error here " + e.toString());
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //         duration: Duration(seconds: 1),
    //         content: Center(
    //             child: SizedBox(
    //                 height: 70,
    //                 child: Center(
    //                   child: Text(
    //                     "Error submitting proposal",
    //                     style: TextStyle(
    //                         fontSize: 24, color: Color.fromARGB(255, 67, 18, 14)),
    //                   ),
    //                 )))));
    //   }

    //   Navigator.of(context).push(MaterialPageRoute(
    //       builder: (context) => Scaffold(
    //           body:
    //               //  DaoSetupWizard())
    //               // Center(child: TransferWidget(org: orgs[0],)))
    //               DAO(InitialTabIndex: 1, org: widget.org))));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.only(
            left: widget.stage == 1 ? 50.0 : 0), // Offset padding for alignment
        child: Container(
            constraints: BoxConstraints(
                minWidth: 600,
                minHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: 1000,
                maxHeight: MediaQuery.of(context).size.height * 0.9),
            // Restrict height
            child: widget.stage == -1
                ? const Center(child: AwaitingConfirmation())
                : widget.stage == 0
                    ? setInfo()
                    : buildTransactionSet()),
      ),
    );
  }

  setInfoDone() {
    setState(() {
      widget.stage = 1;
    });
  }

  Widget setInfo() {
    return NewProposal(p: widget.p, next: setInfoDone);
  }

  Widget buildTransactionSet() {
    return Stack(
      children: [
        // Content and scroll area
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 80), // Prevent scroll overlap with Submit button
            child: Scrollbar(
              controller:
                  _scrollController, // Attach the ScrollController to the Scrollbar
              child: SingleChildScrollView(
                controller:
                    _scrollController, // Attach the same ScrollController to the ScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Align to top
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (index > 0)
                                      const SizedBox(
                                        height: 36,
                                        child: Divider(
                                          thickness: 5,
                                          color: Color.fromARGB(
                                              255, 114, 114, 114),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    // Dropdown for selecting token
                                    SizedBox(
                                      width: 460, // Ensure consistent width
                                      child: DropdownButtonFormField<Token>(
                                        value: transactions[index]['token'],
                                        onChanged: (value) {
                                          setState(() {
                                            transactions[index]['token'] =
                                                value!;
                                          });
                                          validateTransactions(); // Revalidate on token change
                                        },
                                        items: widget.treasury.keys
                                            .map((Token token) {
                                          return DropdownMenuItem<Token>(
                                            value: token,
                                            child: Text(token.symbol),
                                          );
                                        }).toList(),
                                        decoration: const InputDecoration(
                                          labelText: "Asset Type",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Display available amount for selected token
                                    if (transactions[index]['token'] != null)
                                      SizedBox(
                                        width: 460,
                                        child: Text(
                                          'Available: ${displayTokenValue(widget.treasury[transactions[index]['token']]!, transactions[index]['token'].decimals)} ${transactions[index]['token'].symbol}',
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    // Recipient address input
                                    SizedBox(
                                      width: 460, // Ensure consistent width
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            transactions[index]['recipient'] =
                                                value;
                                            validateTransactions(); // Revalidate on text change
                                          });
                                        },
                                        maxLength: 42,
                                        style: const TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: "Recipient Address",
                                          errorText: transactions[index]
                                                      ['recipientError']
                                                  .isNotEmpty
                                              ? transactions[index]
                                                  ['recipientError']
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Amount input
                                    SizedBox(
                                      width: 460, // Ensure consistent width
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            transactions[index]['amount'] =
                                                value;
                                            validateTransactions();
                                            widget.p.value =
                                                double.parse(value);
                                            // Revalidate on text change
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: "Amount",
                                          errorText: transactions[index]
                                                      ['amountError']
                                                  .isNotEmpty
                                              ? transactions[index]
                                                  ['amountError']
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              // Close button or invisible placeholder to keep alignment
                              if (index > 0)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 40), // Add 40px top padding
                                  child: IconButton(
                                    onPressed: () => removeTransaction(index),
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                  ),
                                )
                              else
                                const SizedBox(
                                    width:
                                        48), // Invisible placeholder for first item
                            ],
                          ),
                        );
                      },
                    ),
                    // Add transaction button with placeholder for alignment
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     SizedBox(
                    //       width: 460, // Ensure consistent width
                    //       height: 40,
                    //       child: TextButton(
                    //         style: ButtonStyle(
                    //           elevation: const MaterialStatePropertyAll(0.1),
                    //         ),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: const [
                    //             Icon(Icons.add),
                    //             SizedBox(width: 20),
                    //             Text("Add Transaction"),
                    //           ],
                    //         ),
                    //         onPressed: addTransaction,
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //         width:
                    //             48), // Invisible space to align with close button
                    //   ],
                    // ),
                    // const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Submit button 50px above the bottom with placeholder for alignment
        // Positioned(
        //   bottom: 30, // Submit button 30px above the bottom
        //   left: 0,
        //   right: 0,
        //   child: Center(
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         SizedBox(
        //           height: 40,
        //           width: 160, // Ensure consistent width
        //           child: TextButton(
        //             style: ButtonStyle(
        //               overlayColor: MaterialStateProperty.all<Color>(
        //                   Theme.of(context).indicatorColor),
        //               backgroundColor: isSubmitEnabled
        //                   ? MaterialStateProperty.all<Color>(
        //                       Theme.of(context).indicatorColor)
        //                   : MaterialStateProperty.all<Color>(
        //                       Colors.grey), // Disabled color
        //               elevation: MaterialStateProperty.all(1.0),
        //               shape: MaterialStateProperty.all(
        //                 RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(7.0),
        //                 ),
        //               ),
        //             ),
        //             onPressed: isSubmitEnabled
        //                 ? submitTransactions
        //                 : null, // Enable/disable based on validation
        //             child: const Center(
        //               child: Text(
        //                 "SUBMIT",
        //                 style: TextStyle(
        //                     fontSize: 16,
        //                     fontWeight: FontWeight.bold,
        //                     color: Colors.black),
        //               ),
        //             ),
        //           ),
        //         ),
        //         const SizedBox(
        //             width: 48), // Invisible space to align with close button
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
