import 'package:Homebase/utils/reusable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:graphite/graphite.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import '../main.dart';
import '../screens/account.dart';

class Wait extends StatelessWidget {
  @override
  build(BuildContext context) {
    return const Center(
        child: SizedBox(
            width: 300,
            height: 3,
            child: Opacity(opacity: 0.6, child: LinearProgressIndicator())));
  }
}

class DelegationBoxes extends StatefulWidget {
  Member m;
  AccountState accountState;
  Org org;
  bool busy = false;

  DelegationBoxes(
      {super.key,
      required this.m,
      required this.accountState,
      required this.org});

  @override
  _DelegationBoxesState createState() => _DelegationBoxesState();
}

class _DelegationBoxesState extends State<DelegationBoxes> {
  bool isVoteDirectlyEnabled = true; // Default to Vote Directly enabled
  bool showBothOptions = false; // Initially show both options
  int numDelegatedAccounts = 5; // Placeholder value
  String delegateAddress = "0x3Af8...43bae"; // Placeholder address

  @override
  Widget build(BuildContext context) {
    if (widget.m.delegate == "") {
      print("we should show both options");
      showBothOptions = true;
    } else if (widget.m.delegate.toLowerCase() ==
        Human().address!.toLowerCase()) {
      showBothOptions = false;
      isVoteDirectlyEnabled = true;
      numDelegatedAccounts = widget.m.constituents.length;
    } else {
      showBothOptions = false;
      isVoteDirectlyEnabled = false;
      delegateAddress = getShortAddress(widget.m.delegate);
    }

    Widget delegateYourVoteBottomWidget;
    Widget voteDirectlyBottomWidget;

    if (showBothOptions) {
      // Initial state: show both buttons
      delegateYourVoteBottomWidget = widget.busy
          ? Wait()
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor,
              ),
              onPressed: _setDelegate,
              child: const Text('Set Delegate'),
            );

      voteDirectlyBottomWidget = widget.busy
          ? Wait()
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor,
              ),
              onPressed: _claimVotingPower,
              child: const Text('Claim Voting Power'),
            );
    } else if (isVoteDirectlyEnabled) {
      // When Vote Directly is enabled
      voteDirectlyBottomWidget = widget.busy
          ? Wait()
          : numDelegatedAccounts == 1
              ? const Padding(
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Text("Only voting your your behalf"),
                )
              : RichText(
                  text: TextSpan(
                    text: 'Voting on behalf of ',
                    style: const TextStyle(
                        fontFamily: "Cascadia Code",
                        fontSize: 16,
                        color: Colors.white),
                    children: [
                      TextSpan(
                        text: '$numDelegatedAccounts accounts',
                        style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).indicatorColor,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _showAccountsPopup,
                      ),
                    ],
                  ),
                );

      delegateYourVoteBottomWidget = widget.busy
          ? Wait()
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor,
              ),
              onPressed: _setDelegate,
              child: const Text('Set Delegate'),
            );
    } else {
      // When Delegate Your Vote is enabled
      delegateYourVoteBottomWidget = widget.busy
          ? Wait()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '$delegateAddress',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).indicatorColor,
                  ),
                  onPressed: () {
                    _setDelegate();
                  },
                  child: const Icon(Icons.edit),
                ),
              ],
            );

      voteDirectlyBottomWidget = widget.busy
          ? Wait()
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor,
              ),
              onPressed: _claimVotingPower,
              child: const Text('Claim Voting Power'),
            );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildContainer(
            context,
            icon: Icons.handshake,
            title: "DELEGATE\nYOUR VOTE",
            description:
                "If you can't or don't want to take part in the governance process, your voting privilege may be forwarded to another member of your choosing.",
            bottomWidget: delegateYourVoteBottomWidget,
          ),
          const SizedBox(width: 40),
          _buildContainer(
            context,
            icon: Icons.how_to_vote,
            title: "VOTE\nDIRECTLY",
            description:
                "This also allows other members to delegate their vote to you, so that you may participate in the governance process on their behalf.",
            bottomWidget: voteDirectlyBottomWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Widget bottomWidget,
  }) {
    return Container(
      width: 400,
      height: 290,
      decoration: BoxDecoration(
        color: const Color.fromARGB(38, 0, 0, 0),
        border: Border.all(
          width: 0.3,
          color: const Color.fromARGB(255, 105, 105, 105),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 9),
          // Title row with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Description text
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: RichText(
                    text: TextSpan(
                        text: description,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w100))),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bottom widget
          bottomWidget,
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAccountsPopup() {
    List<Widget> delegatees = [];
    for (Member constituent in widget.m.constituents) {
      delegatees.add(
        Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(border: Border.all(width: 0.3, color: Colors.grey)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              Text(constituent.address),
              const SizedBox(width: 40),
              Text(
                constituent.personalBalance.toString(),
                style: TextStyle(color: Theme.of(context).indicatorColor),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$numDelegatedAccounts Constituents:'),
              const Spacer(),
              const OldSchoolLink(
                  text: "Download CSV", url: "https://something.com")
            ],
          ),
          content: Container(
              width: 700,
              height: 500,
              child: ListView(
                children: delegatees,
              )),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _setDelegate() {
    TextEditingController newDelegateController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Set Delegate"),
              content: Container(
                padding: const EdgeInsets.all(70),
                width: 500,
                height: 340,
                child: widget.busy
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: newDelegateController,
                            maxLength: 42,
                            maxLines: 1,
                            decoration: const InputDecoration(
                                labelText: "Enter the address of the delegate"),
                          ),
                          const SizedBox(height: 80),
                          TextButton(
                            child: const Text("Submit"),
                            onPressed: () async {
                              setState(() {
                                widget.busy = true;
                              });
                              String delegateAddress =
                                  newDelegateController.text;
                              widget.m.delegate = delegateAddress;
                              var memberDoc = await daosCollection
                                  .doc(widget.org.address)
                                  .collection("members")
                                  .doc(widget.m.address)
                                  .set(widget.m.toJson());
                              widget.accountState.setState(() {
                                widget.accountState.widget.member =
                                    widget.org.refreshMember(widget.m);
                              });
                              setState(() {
                                widget.busy = false;
                                showBothOptions = false;
                                isVoteDirectlyEnabled = false;
                                widget.busy = false;
                              });
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
              ),
            ));
  }

  void _claimVotingPower() async {
    setState(() {
      widget.busy = true;
      widget.m.delegate = widget.m.address;
    });
    await daosCollection
        .doc(widget.org.address)
        .collection("members")
        .doc(widget.m.address)
        .set(widget.m.toJson());
    widget.accountState.setState(() {
      widget.accountState.widget.member = widget.org.refreshMember(widget.m);
    });

    setState(() {
      showBothOptions = false;
      widget.busy = false;
    });
  }
}
