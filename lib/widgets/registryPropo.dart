import 'package:Homebase/entities/definitions.dart';
import 'package:Homebase/widgets/newProposal.dart';
import 'package:flutter/material.dart';
import '../entities/contractFunctions.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/dao.dart';
import 'package:lottie/lottie.dart';

import 'initiative.dart';

class RegistryProposalWidget extends StatefulWidget {
  Proposal p;
  Org org;
  int stage = 0;
  State proposalsState;
  InitiativeState initiativeState;
  bool isSetInfo = false;
  RegistryProposalWidget(
      {super.key,
      required this.initiativeState,
      required this.proposalsState,
      required this.p,
      required this.org}) {
    p.type = "registry";
  }

  @override
  State<RegistryProposalWidget> createState() => _RegistryProposalWidgetState();
}

class _RegistryProposalWidgetState extends State<RegistryProposalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final FocusNode _keyFocusNode = FocusNode();
  final FocusNode _valueFocusNode = FocusNode();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _keyFocusNode.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.initiativeState.widget.p.type = "registry";

    // Add focus listeners for the focus nodes
    _keyFocusNode.addListener(() {
      if (!_keyFocusNode.hasFocus) {
        runLogic();
      }
    });

    _valueFocusNode.addListener(() {
      if (!_valueFocusNode.hasFocus) {
        runLogic();
      }
    });
  }

  finishSettingInfo() {
    setState(() {
      widget.isSetInfo = false;
      widget.p.type = "registry";
    });
  }

  runLogic() {
    List<String> params = [_keyController.text, _valueController.text];
    widget.initiativeState.widget.p.callDatas = [];
    String calldata0 = getCalldata(editRegistryDef, params);
    widget.initiativeState.widget.p.callDatas.add(calldata0);
    widget.initiativeState.widget.p.targets = [widget.p.org.registryAddress!];
    widget.initiativeState.widget.p.values = ["0"];
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSetInfo
        ? NewProposal(p: widget.p, next: finishSettingInfo)
        : widget.stage == -1
            ? const AwaitingConfirmation()
            : Form(
                key: _formKey,
                child: Container(
                  width: 650,
                  padding: const EdgeInsets.all(26.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.0),
                        child: TextFormField(
                          focusNode: _keyFocusNode,
                          onChanged: (value) {},
                          controller: _keyController,
                          decoration: const InputDecoration(
                              labelText: 'Key to add or edit'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a key'
                              : null,
                        ),
                      ),
                      TextFormField(
                        focusNode: _valueFocusNode,
                        maxLines: 6,
                        controller: _valueController,
                        decoration:
                            const InputDecoration(labelText: 'Assign a value'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a value'
                            : null,
                      ),
                      // SubmitButton(
                      //     submit: () async {
                      //       List<String> params = [
                      //         _keyController.text,
                      //         _valueController.text
                      //       ];

                      //       widget.p.callDatas = [];
                      //       String calldata0 =
                      //           getCalldata(editRegistryDef, params);
                      //       widget.p.callDatas.add(calldata0);
                      //       widget.p.targets = [widget.p.org.registryAddress!];
                      //       widget.p.values = ["0"];
                      //       widget.p.createdAt = DateTime.now();
                      //       widget.p.statusHistory
                      //           .addAll({"pending": DateTime.now()});
                      //       setState(() {
                      //         widget.stage = -1;
                      //       });
                      //       try {
                      //         String cevine = await propose(widget.p);
                      //         if (cevine.contains("not ok")) {
                      //           ScaffoldMessenger.of(context)
                      //               .showSnackBar(const SnackBar(
                      //                   duration: Duration(seconds: 1),
                      //                   content: Center(
                      //                       child: SizedBox(
                      //                           height: 70,
                      //                           child: Center(
                      //                             child: Text(
                      //                               "Error submitting proposal",
                      //                               style: TextStyle(
                      //                                   fontSize: 24,
                      //                                   color: Colors.red),
                      //                             ),
                      //                           )))));
                      //           Navigator.of(context).pop();
                      //           return;
                      //         }
                      //         widget.p.status = "pending";
                      //         ScaffoldMessenger.of(context)
                      //             .showSnackBar(const SnackBar(
                      //                 duration: Duration(seconds: 1),
                      //                 content: Center(
                      //                     child: SizedBox(
                      //                         height: 70,
                      //                         child: Center(
                      //                           child: Text(
                      //                             "Proposal submitted",
                      //                             style:
                      //                                 TextStyle(fontSize: 24),
                      //                           ),
                      //                         )))));
                      //       } catch (e) {
                      //         ScaffoldMessenger.of(context)
                      //             .showSnackBar(const SnackBar(
                      //                 duration: Duration(seconds: 1),
                      //                 content: Center(
                      //                     child: SizedBox(
                      //                         height: 70,
                      //                         child: Center(
                      //                           child: Text(
                      //                             "Error submitting proposal",
                      //                             style: TextStyle(
                      //                                 fontSize: 24,
                      //                                 color: Colors.red),
                      //                           ),
                      //                         )))));
                      //       }
                      //       Navigator.of(context).push(MaterialPageRoute(
                      //           builder: (context) => Scaffold(
                      //               body:
                      //                   //  DaoSetupWizard())
                      //                   // Center(child: TransferWidget(org: orgs[0],)))
                      //                   DAO(
                      //                       InitialTabIndex: 1,
                      //                       org: widget.org))));
                      //     },
                      //     isSubmitEnabled: true)
                    ],
                  ),
                ),
              );
  }
}

class SubmitButton extends StatefulWidget {
  SubmitButton(
      {super.key, required this.submit, required this.isSubmitEnabled});
  bool isSubmitEnabled;
  var submit;
  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 160, // Ensure consistent width
      child: TextButton(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all<Color>(
              Theme.of(context).indicatorColor),
          backgroundColor: widget.isSubmitEnabled
              ? WidgetStateProperty.all<Color>(
                  Theme.of(context).indicatorColor)
              : WidgetStateProperty.all<Color>(Colors.grey), // Disabled color
          elevation: WidgetStateProperty.all(1.0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ),
        onPressed: widget.isSubmitEnabled
            ? widget.submit
            : null, // Enable/disable based on validation
        child: const Center(
          child: Text(
            "SUBMIT",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class AwaitingConfirmation extends StatelessWidget {
  const AwaitingConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Transaction pending...",
              style: TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 50),
            SizedBox(
              height: 250,
              width: 250,
              child: Lottie.asset("assets/d4.json"),
            )
          ],
        ),
      ),
    );
  }
}
