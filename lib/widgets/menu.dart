import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';





class TopMenu  extends StatefulWidget  with PreferredSizeWidget{
  const TopMenu({super.key});

  @override
  State<TopMenu> createState() => _TopMenuState();
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(75);
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
         
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0.2,
          title: 
           Container(
        padding: const EdgeInsets.only(top:16.0),
         child: Row(
        children: [
           SvgPicture.asset(
        'assets/logos/homebase_logo.svg',
        semanticsLabel: 'Acme Logo'
        ,height: 33,
        color: Theme.of(context).indicatorColor,
        // color: Colors.red,
           ),
           SizedBox(width: 10),
           const Text(
        'Homebase',
        style: TextStyle(fontFamily: 'CascadiaCode', fontSize: 26, fontWeight: FontWeight.w100),
           ),
        ],
         ),
           ),     
          
          
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:10.0),
              child: DropdownButton<String>(
                      value: selectedValue,
                      hint: const Text('Select an item'),
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
                 padding: const EdgeInsets.only(top:10.0),
              child: TextButton(onPressed:(){}, child: Text("Connect wallet")),
            )
             
          ],
        ),
      ),
    );
  }
}