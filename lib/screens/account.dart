import 'package:flutter/material.dart';

import '../widgets/membersList.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      const  SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 29),
                SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Padding(
                     padding: const EdgeInsets.only(left:35.0),
                     child: SizedBox(height: 36,
                       child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(add1, )),
                     ),
                   ),
                        SizedBox(width: 10),
                        Text("tz1UVpbXS6pAtwPSQdQjPyPoGmVkCsNwn1K5", style: TextStyle(fontSize: 16),),
                        Spacer(),
                         Padding(
                          padding: const EdgeInsets.only(right:18.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(onPressed: (){}, child: const Text("Deposit"))),
                        ),
                            Padding(
                          padding: const EdgeInsets.only(right:18.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(onPressed: (){}, child: const Text("Withdraw"))),
                        ),
                            Padding(
                          padding: const EdgeInsets.only(right:18.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(onPressed: (){}, child: const Text("Unstake Votes"))),
                        ),
                        SizedBox(width: 30)
                  ],
                )
              ),
             const SizedBox(height:10),
              Padding(
                padding: const EdgeInsets.only(left:40,right:40,top:25,bottom:25),
                child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Voting Weight" , style: TextStyle(
                                  fontSize: 17,
                                  color: Theme.of(context).indicatorColor ),),
                                const SizedBox(height: 10,),
                                const Text("320000", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              ],
                            ),
                            Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Personal Balance" , style: TextStyle(fontSize: 17,color: Theme.of(context).indicatorColor ),),
                                const SizedBox(height: 10,),
                                const Text("0", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              ],
                            ),
                            Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Proposals Created" , style: TextStyle(fontSize: 17,color: Theme.of(context).indicatorColor ),),
                                const SizedBox(height: 10,),
                                const Text("5", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                            ],
                          ),
                            Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Votes Cast" , style: TextStyle(fontSize: 17,color: Theme.of(context).indicatorColor ),),
                                const SizedBox(height: 10,),
                                const Text("35", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                            ],
                          ),
                          const SizedBox(width: 20)
                        ],
                      ),
                  ),
              ],
            ),
          ),
        ),
       const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text("Delegation (Off-chain)", style: TextStyle(fontSize: 20),),
                  SizedBox(height: 9),
                  const Text("These settings only affect your participation in off-chain polls"),
                    ],
                  ),
                ),
                  SizedBox(height: 9),
                  Divider(),
                  SizedBox(height: 29),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Vote Weight" , style: TextStyle(fontSize: 17,color: Theme.of(context).indicatorColor ),),
                      const SizedBox(height: 10,),
                      const Text("103143.00000 PAC", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                        ],
                      ),
                    ),
                SizedBox(height: 35),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.1, color: Theme.of(context).dividerColor)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left:38.0,right:38.0, top:15,bottom:15),
                    child: Row(
                      children: [
                        Text(""),
                        Spacer(),
                        Text("Not accepting delegations"),
                        Spacer(),
                        ElevatedButton(onPressed: (){}, child: Icon(Icons.edit) )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.1, color: Theme.of(context).dividerColor)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left:38.0,right:38.0, top:15,bottom:15),
                    child: Row(
                      children: [
                        Text(""),
                        Spacer(),
                        Text("Not delegating"),
                        Spacer(),
                        ElevatedButton(onPressed: (){}, child: Icon(Icons.edit) )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}