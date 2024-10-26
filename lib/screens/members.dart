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
    return Column(
      children: [
       const SizedBox(height: 50),
        MembersList(org:widget.org), 
      ],
    );
  }
}