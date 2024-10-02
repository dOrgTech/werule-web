import 'package:flutter/material.dart';
import '../widgets/membersList.dart';


class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       const SizedBox(height: 50),
        MembersList(),
      ],
    );
  }
}