import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homebase/widgets/tokenCard.dart';

class Treasury extends StatefulWidget {
  const Treasury({super.key});

  @override
  State<Treasury> createState() => _TreasuryState();
}

class _TreasuryState extends State<Treasury> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          height: 120,
          
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("DAO Contract Address", style: TextStyle(fontSize: 19),),
                    SizedBox(height: 11),
                    Row(
                      children: [
                        Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5"),
                         SizedBox(width: 20,),
                        TextButton(
                          onPressed: (){},
                          child: const Icon(Icons.copy)),
                      ],
                    )
                  ],
                ),
              ),
              Spacer(),
               Container(
                      padding: EdgeInsets.only(right: 50),
                      height: 40,
                      child: ElevatedButton(
                        child: Text("Propose Transfer",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).indicatorColor)),
                        onPressed: (){}, ),
                    ),

            ],
          )
        ),
        SizedBox(height: 31),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            TokenCard(),TokenCard(),TokenCard(),TokenCard(),TokenCard(),
          ],
        )
      ],
    );
  }
}