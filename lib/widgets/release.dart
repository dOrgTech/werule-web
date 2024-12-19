import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class TestomgTJomgs extends StatefulWidget {
  const TestomgTJomgs({super.key});

  @override
  State<TestomgTJomgs> createState() => _TestomgTJomgsState();
}

class _TestomgTJomgsState extends State<TestomgTJomgs> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specify the address and the voting power of your associates.',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 194, 194, 194),
            ),
          ),
          Text(
            'Voting power is represented by their amount of tokens.\n',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 194, 194, 194),
            ),
          ),
          Text(
            'You may add the members one by one or upload a CSV file with the following format:',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 194, 194, 194),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'address',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 194, 194, 194),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                ', ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 194, 194, 194),
                ),
              ),
              Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'amount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 194, 194, 194),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
