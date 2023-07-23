import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homebase/screens/dao.dart';
import 'package:homebase/screens/explorer.dart';





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
          elevation: 0.2,
          title: 
           Container(
            width: 140,
        padding: const EdgeInsets.only(top:2.0),
         child: InkWell(
          hoverColor: Colors.transparent,
          onTap: () => 
         Navigator.push(
  context,
  MaterialPageRoute(builder: (context) =>Explorer()),
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