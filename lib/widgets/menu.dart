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
            TextButton.icon(
              icon: const Icon(Icons.donut_small),
              label: const Text('Mainnet'),
              
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar')));
              },
            ),
            TextButton(onPressed:(){}, child: Text("Connect wallet"))
             
          ],
        ),
      ),
    );
  }
}