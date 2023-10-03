import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homebase/widgets/cutie.dart';
import 'package:homebase/widgets/hovermenu.dart';
import 'package:homebase/widgets/projectCard.dart';
import '../entities/project.dart';
import '../widgets/footer.dart';
import '../widgets/menu.dart';
List<Project> projects=[
  Project(
   name: "Sample project" ,arbiter: "tz1T5kk65F9oZw2z1YV4osfcrX7eD5KtLj3c",
   description: "If you miss an appointment to voluntarily turn yourself in, they don't usually ask twice so it would be wise to arrive in a timely fashion on this one.",
   client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
   terms: "",
   requirements:"",
   status:"Open"
  ),
  Project(
   name: "Engagement with another DAO" ,arbiter: "tz1T5kk65F9oZw2z1YV4osfcrX7eD5KtLj3c",
   description: "This is the description of the Project. Doesn't need to be super long cause we also link the Terms (on the right) and that should contain all...",
   client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
   terms: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
   status:"Ongoing"
  ),
  Project(
   name: "Sample project" ,arbiter: "tz1T5kk65F9oZw2z1YV4osfcrX7eD5KtLj3c",
   description: "If you miss an appointment to voluntarily turn yourself in, they don't usually ask twice so it would be wise to arrive in a timely fashion on this one.",
   client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
   terms: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
   status:"Dispute"
  ),
   Project( 
   name: "Research decentralized inference" ,arbiter: "tz49jro65F9oZw2z1YV4osfcrX7eD5KtAl2e",
   description: "If you miss an appointment to voluntarily turn yourself in, they don't usually ask twice so it would be wise to arrive in a timely fashion on this one.",
   client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
   terms: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
   status:"Closed"
  ),
   Project( 
   name: "P2P IRC Protocol" ,arbiter: "tz49jro65F9oZw2z1YV4osfcrX7eD5KtAl2e",
   description: "If you miss an appointment to voluntarily turn yourself in, they don't usually ask twice so it would be wise to arrive in a timely fashion on this one.",
   client: "tz1QE8c3H5BG7HGHk2CPs41tffkhLGd14hyu",
   terms: "https://ipfs.io/sdj1wqsa0se0a9fjq2f3fsa1w99jsq",
   status:"Pending"
  ),
];
List<Widget> projectCards=[];
String? selectedStatus = 'All';
String? selectedNewProject="Open to proposals";
  final List<String> statuses = ['All', 'Open', 'Ongoing','Dispute',"Pending","Closed"];
  final List<String> projectTypes = ['Open to proposals', 'Set parties','Import project'];
class Projects extends StatefulWidget {
  const Projects({super.key});
  @override
  State<Projects> createState() {
    return  _ProjectsState();
  }
}

class _ProjectsState extends State<Projects> {
  @override
  void initState() {
    projectCards=[];
    super.initState();
     for (Project p in projects){
      projectCards.add(ProjectCard(project:p));   
    }
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: const TopMenu(),
      body: Container(
          alignment: Alignment.topCenter,
          child: ListView( // Start of ListView
            shrinkWrap: true, // Set this property to true
            children: [
              Column( // Start of Column
                crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                children: [
            const  SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                       height: 46, 
                       width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 1200),
                       child:  MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 0.8),child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Padding(
                              padding: const EdgeInsets.only(left:5.0),
                              child: SizedBox(
                                width: 
                                MediaQuery.of(context).size.width>1200?
                                500:
                                MediaQuery.of(context).size.width * 0.5,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                         borderSide: BorderSide(width: 0.1),
                                      ),
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'Search project',
                                    // other properties
                                  ),
                                  // other properties
                                ),
                              ),
                            ),
                            Row(
                              children: [
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
                                             SizedBox(width: 20),
                                Padding(
                                  padding:  EdgeInsets.only(right:8.0),
                                  child: Row(
                                    children:   [
                                     Text(projects.length.toString()+" Projects"),
                                      SizedBox(width: 60),
                        HoverExpandWidget(),


                      
                      SizedBox(
                        width: 10,
                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            ],
                           ),
                      )),
                    SizedBox(height: 24,),
                   Container(
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 1200),
                     child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.start,
                      children: projectCards as List<Widget>,
                     ),
                   ), 
                  const SizedBox(height: 64),
                   Footer()
                ],
              ), // End of Column
            ],
          ), // End of ListView
        ),
    );
  }
}