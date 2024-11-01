import 'package:flutter/material.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../main.dart';
import '../widgets/membersList.dart';
import '../widgets/voteConcentration.dart';

class Members extends StatefulWidget {
  Members({super.key, required this.org});
  Org org;
  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        SizedBox(
            height: 210,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 50),
                    width: 500,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(width: 0.1),
                        ),
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Find user by address',
                        // other properties
                      ),
                      // other properties
                    ),
                  ),
                  Transform.scale(scale: 0.82, child: VotingPowerWidget())
                ])),
        const SizedBox(height: 30),
        MembersList(org: widget.org),
      ],
    );
  }
}

class Pills extends StatelessWidget {
  const Pills({super.key});

  @override
  Widget build(BuildContext context) {
    Proposal p = Proposal(org: orgs[0], type: "transfer");
    List<Widget> pills = [];
    for (String s in statuses) {
      Widget sp = p.statusPill(s, context);
      pills.add(Container(width: 200, padding: EdgeInsets.all(9), child: sp));
    }
    return Container(
      child: Column(
        children: pills,
      ),
    );
  }
}
