import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class DelegationBoxes extends StatefulWidget {
  @override
  _DelegationBoxesState createState() => _DelegationBoxesState();
}

class _DelegationBoxesState extends State<DelegationBoxes> {
  bool isVoteDirectlyEnabled = true; // Default to Vote Directly enabled
  bool showBothOptions = true; // Initially show both options
  int numDelegatedAccounts = 5; // Placeholder value
  String delegateAddress = "0x3Af8...43bae"; // Placeholder address

  @override
  Widget build(BuildContext context) {
    Widget delegateYourVoteBottomWidget;
    Widget voteDirectlyBottomWidget;

    if (showBothOptions) {
      // Initial state: show both buttons
      delegateYourVoteBottomWidget = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).indicatorColor,
        ),
        onPressed: _setDelegate,
        child: Text('Set Delegate'),
      );

      voteDirectlyBottomWidget = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).indicatorColor,
        ),
        onPressed: _claimVotingPower,
        child: Text('Claim Voting Power'),
      );
    } else if (isVoteDirectlyEnabled) {
      // When Vote Directly is enabled
      voteDirectlyBottomWidget = RichText(
        text: TextSpan(
          text: 'Voting on behalf of ',
          style: TextStyle(
            fontFamily: "Cascadia Code",
            fontSize: 16, color: Colors.white),
          children: [
            TextSpan(
              text: '$numDelegatedAccounts accounts',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).indicatorColor,
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = _showAccountsPopup,
            ),
          ],
        ),
      );

      delegateYourVoteBottomWidget = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).indicatorColor,
        ),
        onPressed: _setDelegate,
        child: Text('Set Delegate'),
      );
    } else {
      // When Delegate Your Vote is enabled
      delegateYourVoteBottomWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '$delegateAddress',
            style: TextStyle(fontSize: 16),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).indicatorColor,
            ),
            onPressed: () {
              // Add your edit delegate logic here
            },
            child: Icon(Icons.edit),
          ),
        ],
      );

      voteDirectlyBottomWidget = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).indicatorColor,
        ),
        onPressed: _claimVotingPower,
        child: Text('Claim Voting Power'),
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
          SizedBox(width: 40),
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
        color: Color.fromARGB(38, 0, 0, 0),
        border: Border.all(
          width: 0.3,
          color: Color.fromARGB(255, 105, 105, 105),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(height: 9),
          // Title row with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          SizedBox(height: 25),
          // Description text
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: RichText(
                  text: TextSpan(
                    text:
                  description,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w100)
                  )
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          // Bottom widget
          bottomWidget,
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAccountsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Accounts'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: numDelegatedAccounts,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('Account ${index + 1}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _setDelegate() {
    setState(() {
      showBothOptions = false;
      isVoteDirectlyEnabled = false;
    });
  }

  void _claimVotingPower() {
    setState(() {
      showBothOptions = false;
      isVoteDirectlyEnabled = true;
    });
  }
}
