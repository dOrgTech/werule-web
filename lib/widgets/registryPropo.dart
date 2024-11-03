import 'package:Homebase/widgets/newProposal.dart';
import 'package:flutter/material.dart';

import '../entities/contractFunctions.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/dao.dart';

class RegistryProposalWidget extends StatefulWidget {
  Proposal p;
  Org org;
  int stage = 0;
  State proposalsState;
  bool isSetInfo = true;
  RegistryProposalWidget(
      {Key? key,
      required this.proposalsState,
      required this.p,
      required this.org})
      : super(key: key) {
    p.type = "registry";
  }

  @override
  State<RegistryProposalWidget> createState() => _RegistryProposalWidgetState();
}

class _RegistryProposalWidgetState extends State<RegistryProposalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // widget.onSubmit(_keyController.text, _valueController.text);
    }
  }

  finishSettingInfo() {
    setState(() {
      widget.isSetInfo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSetInfo
        ? NewProposal(p: widget.p, next: finishSettingInfo)
        : widget.stage == -1
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Awaiting confirmation...",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 200),
                  CircularProgressIndicator(),
                ],
              ))
            : Form(
                key: _formKey,
                child: Container(
                  width: 650,
                  padding: EdgeInsets.all(26.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.0),
                        child: TextFormField(
                          onChanged: (value) {},
                          controller: _keyController,
                          decoration: const InputDecoration(labelText: 'Key'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a key'
                              : null,
                        ),
                      ),
                      TextFormField(
                        maxLines: 6,
                        controller: _valueController,
                        decoration: const InputDecoration(labelText: 'Value'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a value'
                            : null,
                      ),
                      SubmitButton(
                          submit: () async {
                            widget.p.callDatas = [
                              {_keyController.text: _valueController.text}
                            ];
                            widget.p.createdAt = DateTime.now();
                            widget.p.statusHistory
                                .addAll({"pending": DateTime.now()});
                            setState(() {
                              widget.stage = -1;
                            });
                            await makeProposal();
                            await widget.org.pollsCollection
                                .doc(widget.p.id.toString())
                                .set(widget.p.toJson());
                            widget.org.proposals.add(widget.p);
                            widget.org.proposals =
                                widget.org.proposals.reversed.toList();
                            widget.p.status = "pending";
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Scaffold(
                                    body:
                                        //  DaoSetupWizard())
                                        // Center(child: TransferWidget(org: orgs[0],)))
                                        DAO(
                                            InitialTabIndex: 1,
                                            org: widget.org))));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Center(
                                        child: SizedBox(
                                            height: 70,
                                            child: Center(
                                              child: Text(
                                                "Proposal submitted",
                                                style: TextStyle(fontSize: 24),
                                              ),
                                            )))));
                          },
                          isSubmitEnabled: true)
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
          overlayColor: MaterialStateProperty.all<Color>(
              Theme.of(context).indicatorColor),
          backgroundColor: widget.isSubmitEnabled
              ? MaterialStateProperty.all<Color>(
                  Theme.of(context).indicatorColor)
              : MaterialStateProperty.all<Color>(Colors.grey), // Disabled color
          elevation: MaterialStateProperty.all(1.0),
          shape: MaterialStateProperty.all(
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
