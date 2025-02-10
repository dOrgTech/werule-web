import "package:Homebase/debates/models/argument.dart";
import "package:Homebase/screens/proposals.dart";
import "package:Homebase/widgets/propDetailsWidgets.dart";
import "package:Homebase/widgets/registryPropo.dart";
import "package:Homebase/widgets/transfer.dart";
import "package:Homebase/widgets/waiting.dart";
import "package:flutter/material.dart";
import "package:toggle_switch/toggle_switch.dart";
import "package:web3dart/credentials.dart";
import "../debates/models/debate.dart";
import "../entities/contractFunctions.dart";
import "../entities/definitions.dart";
import "../entities/org.dart";
import "../entities/proposal.dart";
import "../entities/token.dart";
import "../screens/dao.dart";
import "../utils/reusable.dart";

class Initiative extends StatefulWidget {
  Initiative({
    required this.org,
    super.key,
  });
  Org org;
  late Debate d;
  late Proposal p;
  late Object thing;
  Widget? proposalType;
  String? propType;
  int phase = 0;
  Map<String, Map<String, double>> assetData = {};
  bool review = false;
  @override
  State<Initiative> createState() => InitiativeState();
}

class InitiativeState extends State<Initiative> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  int _currentPage = 1;
  bool isProposalSelected = true; // Default selection
  bool _isSubmitEnabled = false;
  static const int _entriesPerPage = 50;

  @override
  void initState() {
    super.initState();
    widget.d = Debate(
        org: widget.org,
        rootArgument: Argument(content: _descriptionController.text, weight: 0),
        title: _nameController.text);
    widget.p = Proposal(
      org: widget.org,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.phase) {
      case -1:
        return WaitingOnChain();
      case 0:
        return enterInfo();
      case 1:
        return selectProposalType();
      case 2:
        return review();
      default:
        return enterInfo();
    }
  }

  void _handleToggle(int index) {
    setState(() {
      isProposalSelected = true;
      // isProposalSelected = index == 0; // Set true if "Proposal" is selected
    });
  }

  List<Widget> proposal() {
    return [
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          controller: _nameController,
          onChanged: (value) {
            widget.p.name = value;
          },
          maxLength: 42,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "Proposal Title",
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          controller: _descriptionController,
          onChanged: (value) {
            widget.p.description = value;
          },
          maxLength: 200,
          maxLines: 5,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "Proposal Description",
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          controller: _urlController,
          onChanged: (value) {
            widget.p.externalResource = value;
          },
          maxLength: 262,
          style: const TextStyle(fontSize: 16),
          decoration: const InputDecoration(
            labelText: "Discussion URL",
          ),
        ),
      ),
      const SizedBox(height: 130)
    ];
  }

  bool isBinary = true; // Default selection
  List<Widget> debate() {
    return [
      Row(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _nameController,
              onChanged: (value) {
                widget.p.name = value;
              },
              maxLength: 62,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Debate Title",
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBinary = true; // Switch to Binary mode
                    });
                  },
                  child: Tooltip(
                    message: "Yields a \"Yes\" or \"No\" answer.",
                    textStyle: TextStyle(color: Colors.black87, fontSize: 18),
                    child: Text(
                      "Binary",
                      style: TextStyle(
                        color: isBinary
                            ? Color.fromARGB(255, 255, 255, 255)
                            : Color.fromARGB(
                                255, 138, 138, 138), // Active = white
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Switch(
                  value: !isBinary,
                  onChanged: (value) {
                    setState(() {
                      isBinary = !value;
                      // widget.p
                    });
                  },
                  activeColor: Colors.grey,
                  inactiveThumbColor: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBinary = false; // Switch to Exploratory mode
                    });
                  },
                  child: Tooltip(
                    message: "Great for answering \"How?\" questions.",
                    textStyle: TextStyle(color: Colors.black87, fontSize: 18),
                    child: Text(
                      "Exploratory",
                      style: TextStyle(
                        color: isBinary
                            ? Color.fromARGB(255, 138, 138, 138)
                            : Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      SizedBox(height: 30),
      SizedBox(
        width: 780, // Ensure consistent width
        child: TextFormField(
          maxLines: 19,
          controller: _descriptionController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText:
                'Write or paste your main thesis here (markdown supported)',
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Support your position with one or more arguments.'
              : null,
        ),
      ),
      const SizedBox(height: 30),
    ];
  }

  Widget enterInfo() {
    return Container(
        constraints: BoxConstraints(
            minWidth: 600,
            minHeight: 500,
            maxWidth: 1000,
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: 56),
          ToggleSwitch(
            initialLabelIndex: isProposalSelected ? 0 : 1,
            totalSwitches: 2,
            labels: ['Proposal', 'Debate'],
            activeBgColor: [
              Color.fromARGB(255, 43, 43, 43).withOpacity(0.3)
            ], // Light blue for active state
            inactiveBgColor:
                Theme.of(context).cardColor, // Light grey for inactive state
            activeFgColor: Colors.white,
            inactiveFgColor: Color.fromARGB(255, 105, 105, 105),
            borderColor: [
              Colors.transparent
            ], // Add white border for better visibility
            borderWidth: 1.0, // Border width
            minWidth: 120.0, // Prevent truncation
            cornerRadius: 20.0, // Rounded corners
            onToggle: (index) {
              _handleToggle(index!);
            },
            customTextStyles: [
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ],
          ),
          Spacer(),
          isProposalSelected
              ? Column(children: proposal())
              : Column(children: debate()),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(),
              isProposalSelected == false && isBinary == true
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 180,
                        height: 44,
                        child: TextFormField(
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Weight',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid weight';
                            }
                            final n = int.tryParse(value);
                            if (n == null || n <= 0) {
                              return 'Enter a positive number';
                            }
                            return null;
                          },
                        ),
                      ),
                    )
                  : Text(""),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.phase = 1;
                    });
                  },
                  child: SizedBox(
                      width: 68,
                      height: 45,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next"),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward)
                        ],
                      )))),
              SizedBox(width: 20),
            ],
          )
        ]));
  }

  changeState(Map<String, Map<String, double>> assetData) {
    setState(() {
      widget.assetData = assetData;
      widget.review = true;
      widget.phase = 2;
    });
  }

  setReview(Proposal p) {
    setState(() {
      widget.p = p;
      widget.review = true;
      widget.phase = 2;
    });
  }

  selectProposalType() {
    return !(widget.proposalType == null)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 650, child: widget.proposalType!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          widget.proposalType = null;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back),
                          const SizedBox(width: 8),
                          Text("Back"),
                        ],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        print("proposal type is " + widget.p.type!);
                        setState(() {
                          widget.phase = 2;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next"),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward)
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProposalList(org: widget.org, initiativeState: this, p: widget.p),
              TextButton(
                  onPressed: () {
                    setState(() {
                      widget.phase = 0;
                    });
                  },
                  child: SizedBox(
                      width: 68,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_back),
                          const SizedBox(width: 8),
                          Text("Back"),
                          Spacer()
                        ],
                      ))),
            ],
          ));
  }

  makeList() {
    print("generating transactions now");
    return SizedBox(
      width: 600,
      height: 400,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: widget.assetData.entries.map((entry) {
          print("doing this once with " + entry.key.toString());
          String asset = entry.key;
          Map<String, double> recipients = entry.value;

          double totalAmount = recipients.values.fold(0.0, (a, b) => a + b);

          return Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(117, 49, 49, 49),
                border: Border.all(
                    color: Color.fromARGB(172, 112, 112, 112), width: 0.7)),
            margin: EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                    child: Row(
                      children: [
                        Text(
                          'Total ${asset == 'native' ? 'XTZ' : getShortAddress(asset)} to be transferred: ',
                        ),
                        Text(' $totalAmount',
                            style: TextStyle(
                                color: Theme.of(context).indicatorColor))
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${recipients.length} transactions:', // Added transaction count
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipients.length <= 12)
                        ...recipients.entries.map((recipientEntry) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 3),
                            color: Colors.black38,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 1),
                            child: Row(
                              children: [
                                Text(
                                    '${getShortAddress(recipientEntry.key)} - '),
                                Text(
                                  '${recipientEntry.value}',
                                  style: TextStyle(
                                      color: Theme.of(context).indicatorColor),
                                )
                              ],
                            ),
                          );
                        }).toList()
                      else ...[
                        // Display only the first 4 recipients
                        for (int i = 0; i < 4; i++)
                          Container(
                              margin: EdgeInsets.only(bottom: 3),
                              color: Colors.black38,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 1),
                              child: Row(
                                children: [
                                  Text(
                                      '${getShortAddress(recipients.entries.elementAt(i).key)} -  '),
                                  Text(
                                    '${recipients.entries.elementAt(i).value}',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).indicatorColor),
                                  )
                                ],
                              )),

                        // Display an ellipsis if there are more recipients
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('...'),
                        ),
                        // Display the last 4 recipients
                        for (int i = recipients.length - 4;
                            i < recipients.length;
                            i++)
                          Container(
                              margin: EdgeInsets.only(bottom: 3),
                              color: Colors.black38,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 1),
                              child: Row(
                                children: [
                                  Text(
                                      '${getShortAddress(recipients.entries.elementAt(i).key)} -  '),
                                  Text(
                                    '${recipients.entries.elementAt(i).value}',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).indicatorColor),
                                  )
                                ],
                              )),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  review() {
    print("we're here now");
    widget.propType = widget.p.type == null ? "null" : widget.p.type!;
    print("proposal tyupe is" + widget.propType!);
    return Container(
      height: 700,
      constraints: BoxConstraints(minWidth: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(width: 0.5, color: Colors.white12)),
            child: Text("${widget.p.type!} proposal"),
          ),
          SizedBox(height: 16),
          Text(
            widget.p.name ?? "No title",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 400,
              child: Center(
                  child: Text(widget.p.description!,
                      style: TextStyle(fontSize: 14))),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 30,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Discussion: ",
                    style: TextStyle(fontSize: 14),
                  ),
                  OldSchoolLink(
                      text: widget.p.externalResource!.length < 42
                          ? widget.p.externalResource!
                          : widget.p.externalResource!.substring(0, 42) + "...",
                      url: widget.p.externalResource!)
                ],
              ),
            ),
          ),
          SizedBox(height: 36),
          SingleChildScrollView(
              child: widget.p.type == "batch transfer"
                  // child: true
                  ? makeList()
                  : widget.p.type == "transfer"
                      ? SizedBox(
                          height: 400,
                          width: 600,
                          child: TokenTransferListWidget(p: widget.p))
                      : widget.p.type == "registry"
                          ? SizedBox(
                              height: 400,
                              width: 600,
                              child: RegistryProposalDetails(p: widget.p))
                          : widget.p.type == "contract call"
                              ? ContractCall(p: widget.p)
                              : widget.p.type!.toLowerCase().contains("mint") ||
                                      widget.p.type!
                                          .toLowerCase()
                                          .contains("burn")
                                  ? GovernanceTokenOperationDetails(
                                      p: widget.p,
                                    )
                                  : widget.p.type!.contains("quorum") ||
                                          widget.p.type!
                                              .contains("voting delay") ||
                                          widget.p.type!
                                              .contains("voting period") ||
                                          widget.p.type!.contains("threshold")
                                      ? SizedBox(
                                          child: DaoConfigurationDetails(
                                              p: widget.p))
                                      // DaoConfigurationDetails(p: widget.p)
                                      : const Text("")),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.proposalType = null;
                      widget.phase = 1;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      const SizedBox(width: 8),
                      Text("Back"),
                    ],
                  ),
                ),
                Spacer(),
                SubmitButton(
                    submit: () async {
                      print("sending proposal");
                      print("proposal type is " + widget.p.type!);
                      print("targets are " + widget.p.targets.toString());
                      print("values are " + widget.p.values.toString());
                      print("calldatas are " + widget.p.callDatas.toString());
                      await sendProposal();
                    },
                    isSubmitEnabled: true)
              ],
            ),
          ),
          SizedBox(height: 14),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> transactions = [];

  sendProposal() async {
    if (widget.p.type == "transfer" && widget.assetData.isNotEmpty) {
      await submitTransactions();
    }
    await submit();
  }

  submit() async {
    print("now submitting");
    widget.p.createdAt = DateTime.now();
    widget.p.statusHistory.addAll({"pending": DateTime.now()});

    setState(() {
      widget.phase = -1;
    });
    print("we set the state");
    try {
      print("getting ready for it");
      String cevine = await propose(widget.p);
      if (cevine.contains("not ok")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            content: Center(
                child: SizedBox(
                    height: 70,
                    child: Center(
                      child: Text(
                        "Error submitting proposal",
                        style: TextStyle(
                            fontSize: 24,
                            color: Color.fromARGB(255, 67, 18, 14)),
                      ),
                    )))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
      }
    } catch (e) {
      print("some error here " + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          content: Center(
              child: SizedBox(
                  height: 70,
                  child: Center(
                    child: Text(
                      "Error submitting proposal",
                      style: TextStyle(
                          fontSize: 24, color: Color.fromARGB(255, 67, 18, 14)),
                    ),
                  )))));
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
            body:
                //  DaoSetupWizard())
                // Center(child: TransferWidget(org: orgs[0],)))
                DAO(InitialTabIndex: 1, org: widget.org))));
  }

  submitTransactions() async {
    print("submitting transactions");
    widget.assetData.forEach((key, value) {
      print("adding token" + key);
      String token_address = key;
      value.forEach((key, value) {
        print("adding transaction " + key + " - " + value.toString());
        transactions.add({
          'token': token_address,
          'recipient': key,
          'amount': value.toString(),
          'recipientError': [],
          'amountError': []
        });
      });
    });
    widget.p.values = [];
    widget.p.targets = [];
    widget.p.callDatas = [];
    widget.p.type = "transfer";
    for (var tx in transactions) {
      print("we're here");
      print(tx);
      List params = [];
      print("tx['token'] is " + tx['token'].toString());
      if (tx['token'].toString().contains("native")) {
        print("we got so myuch native ${tx['amount']}");
        double txamount = double.parse(tx['amount'].toString());
        final BigInt weiAmount = BigInt.from(txamount);
        print("we createdbg");
        params = [EthereumAddress.fromHex(tx['recipient']), weiAmount];
        print("getting calldata");
        widget.p.callDatas.add(getCalldata(transferNativeDef, params));
        print("got it");
      } else {
        print("we got so myuch erc20 ");
        params = [
          tx['token'],
          tx['recipient'],
          tx['amount'],
        ];
        widget.p.callDatas.add(getCalldata(transferErc20Def, params));
      }
      widget.p.targets.add(widget.org.registryAddress!);
      widget.p.values.add("0");
    }
  }
}
