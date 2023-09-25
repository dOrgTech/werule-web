import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';
import 'package:homebase/utils/functions.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/projects.dart';
import '../screens/users.dart';
bool isConnected = false;
String us3rAddress= generateWalletAddress();
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
                totalSwitches: 3,
                minWidth: 120,
                borderWidth: 1.5,
                activeBgColor: [Theme.of(context).cardColor],
                inactiveBgColor: Theme.of(context).canvasColor,
                borderColor: [Theme.of(context).cardColor],
                labels: ['DAOs','Projects','Users'],
                onToggle: (index) {
                  print('switched to: $index');
                  Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => index==0?Explorer():index==1?Projects():Users()
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
              child: TextButton(onPressed:(){}, child: WalletButton()),
            )
             
          ],
        ),
      ),
    );
  }
}

class WalletButton extends StatefulWidget {
  const WalletButton({Key? key}) : super(key: key);

  @override
  _WalletButtonState createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  bool _isConnecting = false;
   // Assuming this state is managed
    // Assuming this is a placeholder

  void _connectWallet() {
    setState(() {
      _isConnecting = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isConnecting = false;
        isConnected = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
  return SizedBox(
    width: 180,
    child: LinearProgressIndicator(),
  );
}

    if (!isConnected) {
      return SizedBox(
        width: 180,
        child: TextButton(
          onPressed: _connectWallet,
          child: Text("Connect Wallet"),
        ),
      );
    }

    return SizedBox(
      width: 180,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: Colors.transparent,
          isExpanded: true,
          value: 'Connected',
          icon: Icon(Icons.arrow_drop_down),
          hint: Text(shortenString(us3rAddress)),
          onChanged: (value) {
            // Implement actions based on dropdown selection
          },
          items: [
            DropdownMenuItem(
              value: 'Connected',
              child: Text(shortenString(us3rAddress)),
            ),
            DropdownMenuItem(
              value: 'Profile',
              child: Text('Profile'),
            ),
            DropdownMenuItem(
              value: 'Switch Address',
              child: Text('Switch Address'),
            ),
            DropdownMenuItem(
              value: 'Disconnect',
              child: Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}






