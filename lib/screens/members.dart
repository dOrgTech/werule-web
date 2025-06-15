import 'package:flutter/material.dart';
import '../entities/org.dart';
import '../widgets/membersList.dart';

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
        const SizedBox(height: 20),
        SizedBox(
            height: 80,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 50),
                    width: 500,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(width: 0.1),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Find user by address',
                        // other properties
                      ),
                      // other properties
                    ),
                  ),
                  // Transform.scale(
                  //     scale: 0.82, child: VotingPowerWidget(org: widget.org))
                ])),
        const SizedBox(height: 30),
        MembersList(org: widget.org),
      ],
    );
  }
}
