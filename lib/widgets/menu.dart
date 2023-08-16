import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/projects.dart';

int status=0;
class TopMenu  extends StatefulWidget  with PreferredSizeWidget{
  const TopMenu({super.key});

  @override
  State<TopMenu> createState() => _TopMenuState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _TopMenuState extends State<TopMenu> {
  final List<String> items = ['  Mainnet', '  Ghostnet'];

  // The current selected value of the dropdown
  String? selectedValue = '  Mainnet';
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: 1200,
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          title: 
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(
                width: 140,
        padding: const EdgeInsets.only(top:2.0),
         child: InkWell(
          hoverColor: Colors.transparent,
          onTap: () => 
         Navigator.push(
  context,
  MaterialPageRoute(builder: (context) =>status==0?Explorer():Projects()),
),
               child: Row(
                     children: [
                    
                    SvgPicture.asset(
                           'assets/logos/homebase_logo.svg',
                           semanticsLabel: 'Acme Logo'
                           ,height: 25,
                           color: Theme.of(context).indicatorColor,
                           // color: Colors.red,
                     ),
                   
                 
                 SizedBox(width: 10),
                 const Text(
                     'Homebase',
                     style: TextStyle(fontFamily: 'CascadiaCode', fontSize: 21, fontWeight: FontWeight.w100),
                 ),
                     ],
               ),
         ),
               ),
                SizedBox(
              height: 32,
              
              child: ToggleSwitch(
                initialLabelIndex: status,
                totalSwitches: 2,
                minWidth: 120,
                borderWidth: 1.5,
                activeBgColor: [Theme.of(context).cardColor],
                inactiveBgColor: Theme.of(context).canvasColor,
                borderColor: [Theme.of(context).cardColor],
                labels: ['DAOs', 'Projects'],
                onToggle: (index) {
                  print('switched to: $index');
                  Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => index==0?Explorer():Projects(),
              ),
            );
            setState(() {
              status=index!;
            });
              },
            ),
            ),
              Padding(
                padding: const EdgeInsets.only(right:24),
                child: Row(
                  children: [
                    SizedBox(
                          height: 38,
                              width: 38,
                          child: TextButton(
                            onPressed: () {launch("https://discord.gg/XufcBNu277");},
                            child: Image.network(
                              "https://i.ibb.co/Nr7Psjm/discord.png",
                              color: Color.fromARGB(255, 196, 196, 196),
                              
                            ),)
                        ),
                    SizedBox(
                      height: 38,
                      width: 38,
                      child: TextButton(
                        child: Icon(Icons.info),
                        onPressed: (){}),
                    )
                  ],
                ),
              ),
      
             ],
           ),     
          
          
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:1.0),
              child: DropdownButton<String>(
                      value: selectedValue,
                      focusColor: Colors.transparent,
                      items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
                      }).toList(),
                      onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue;
              });
                      },
                    ),
            ),
            const SizedBox(width: 20 ),
            Padding(
                 padding: const EdgeInsets.only(top:1.0, right:15),
              child: TextButton(onPressed:(){}, child: Text("Connect wallet")),
            )
             
          ],
        ),
      ),
    );
  }
}