

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:homebase/entities/proposal.dart';
import 'package:homebase/utils/theme.dart';
import 'package:homebase/widgets/proposalCard.dart';

class Proposals extends StatefulWidget {
  const Proposals({super.key});

  @override
  State<Proposals> createState() => _ProposalsState();
}

class _ProposalsState extends State<Proposals> {
  String? selectedType = 'All';
  final List<String> types = ['All', 'Off-Chain', 
  'Transfer', 'Add Lambda', 'Remove Lambda', 'Execute Lambda',
   'Change Config','Change Guardian','Change Delegate'];
  String? selectedStatus = 'All';
  final List<String> statuses = ['All', 'Active', 
  'Dropped', 'Passed','Executable', 'Executed', 'Expired',
   'No Quorum','Pending','Rejected'];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               const SizedBox(width: 40),
               const Text("Type:"),
               const SizedBox(width: 10),

                DropdownButton<String>(
                      value: selectedType,
                      focusColor: Colors.transparent,
                      items: types.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
                      }).toList(),
                      onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue;
              });
                  },
                    ),
                      const SizedBox(width: 40),
               const Text("Status:"),
               const SizedBox(width: 10),
                DropdownButton<String>(
                      value: selectedStatus,
                      focusColor: Colors.transparent,
                      items: statuses.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
                      }).toList(),
                      onChanged: (String? newValue) {
              setState(() {
                selectedStatus = newValue;
              });
                  },
                    ),
                    Spacer(),
                     Padding(
                      padding: const EdgeInsets.only(right:18.0),
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(onPressed: (){}, child: const Text("Execute/Drop All"))),
                    ),
                Container(
                  padding: EdgeInsets.only(right: 50),
                  height: 40,
                  child: ElevatedButton(
                    child: Text("Create Proposal",
                    style: TextStyle( fontSize: 16, color: Theme.of(context).primaryColorDark),
                    ),
                    style: ButtonStyle(
                      elevation:MaterialStatePropertyAll(0.0),
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).indicatorColor)),
                    onPressed: (){
                      showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return  AlertDialog(
                                  title: Padding(
                                    padding: const EdgeInsets.only(left:18.0),
                                    child: Text("Select a proposal type"),
                                  ),
                                  content: ProposalList(),
                                  
                                );
                              },
                            );

                    },),
                ),
              ],
            )
          ),
          SizedBox(height: 40),
          Container(
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Container(
                  padding: EdgeInsets.only(left:15  ),
                  width: 90,
                  child: Text("ID #")),
              ),
              Expanded(
                child: Container(
                  width:230, child: Padding(
                    padding: const EdgeInsets.only(left:48.0),
                    child: Text("Title"),
                  )),
              ),
              Container(
                width: 230,
                child: Center(child: Text("Author"))),    
              SizedBox(width:150,child: Center(child: Text("Posted"))),
              SizedBox(width: 150, child: Center(child: Text("Type "))),
              SizedBox(width:100, child: Center(child: Text("Status "))),
            ],
          ),
      ),
    ), 
        ProposalCard(proposal:new Proposal(type: "New Project", name: "Engagement with another DAO")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
        ProposalCard(proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)")),
       
        ],
      ),
    );
  }
}


class ProposalList extends StatelessWidget {
  const ProposalList({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget>propuneri=[];

    for (String item in proposalTypes.keys){
      propuneri.add(Card(
        child: Container(
          color: Theme.of(context).hoverColor,
          padding: EdgeInsets.all(3),
          width: 300, height: 160,
          child: TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              showDialog( context:context,  builder: (BuildContext context) {
                                return  AlertDialog(
                                  title: Padding(
                                    padding: const EdgeInsets.only(left:18.0),
                                    child: Text(item.toString()),
                                  ),
                                  content: newProposalWidgets[item],
                                  
                                );
                              },
                            );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(item), Text(proposalTypes[item]!)
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }

    var marime=MediaQuery.of(context).size;
    return SizedBox(
      width: MediaQuery.of(context).size.aspectRatio>1?
      marime.width/2:marime.width*0.9,
      height:  MediaQuery.of(context).size.aspectRatio>1?
      marime.height/1.4:marime.height*0.9
      ,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Padding(
                padding: const EdgeInsets.only(left:12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Learn about the different types of Homebase proposals from ", style: TextStyle(fontSize: 12),),
                    Text("here.", style:TextStyle(color: Theme.of(context).indicatorColor,fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: 52,),
              Center(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: propuneri,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}