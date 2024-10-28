import 'package:Homebase/entities/contractFunctions.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import '../entities/token.dart';
import '../main.dart';
import '../widgets/gameOfLife.dart';
import '../widgets/menu.dart';
import '../entities/org.dart';
import '../widgets/daocard.dart';
import '../widgets/footer.dart';
import 'creator.dart';
class Explorer extends StatefulWidget {
  const Explorer({super.key});

  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  @override
  Widget build(BuildContext context) {
    print("building explorer" + orgs.length.toString());

    List<Widget> daos=[];

    for (var org in orgs) {
      print("adding a dao");
      daos.add(DAOCard(org:org as Org));}
    
    return Scaffold(
      appBar: const TopMenu(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
         child: Stack(
           children: [
          Opacity(
                  opacity: 0.03,
                  child: GameOfLife()),
            Container(
                alignment: Alignment.topCenter,
                child: ListView( // Start of ListView
                  shrinkWrap: true, // Set this property to true
                  children: [
                    Column( // Start of Column
                      crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                      mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                      children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                             height: 80, 
                             width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 1200),
                             child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              Padding(
                                padding: const EdgeInsets.only(left:5.0),
                                child: SizedBox(
                                  width: 
                                  MediaQuery.of(context).size.width>1200?
                                  550:
                                  MediaQuery.of(context).size.width * 0.5,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                           borderSide: BorderSide(width: 0.1),
                                        
                                        ),
                                      prefixIcon: Icon(Icons.search),
                                      hintText: 'Search by DAO Name or Token Symbol',
                                      // other properties
                                    ),
                                    // other properties
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right:8.0),
                                child: Row(
                                  children: [
                                    Text( orgs.length.toString()+ " DAOs"),
                                    SizedBox(width: 30,),
                                    SizedBox(
                                      height: 40,
                                      child: ElevatedButton(onPressed: (){
                                        Token tkn=Token(
                                          name:"TeZBugHunt",
                                          decimals: 18,
                                          symbol: "BGT"
                                        );
                                        Org org=Org(
                                          name: "TezBugHunt",
                                          govToken: tkn,
                                          description: "We hunting bugs",
                                        );
                                        Navigator.push(context, 
                                        MaterialPageRoute(builder: (context)=>
                                         Scaffold(body:
                                        DaoSetupWizard())
                                        ));
                                        
                                      }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).indicatorColor),
                                      child: Text("Start a Company", 
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CascadiaCode', fontSize: 18, fontWeight: FontWeight.w100),)),
                                    )
                                  ],
                                ),
                              )
                              ],
                             ),
                            ),
                          SizedBox(height: 10,),
                         Container(
                          alignment: Alignment.topCenter,
                          width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 1200),
                           child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: 
                            daos as List<Widget>,
                           ),
                         )
                      ],
                    ), // End of Column
                  SizedBox(height: 23),
                
          // other widgets
          
       
                  ],
                ), // End of ListView
              ),
          ],
        ),
      ),
    );
  }
}