import 'package:flutter/material.dart';
class RegItemCard extends StatelessWidget {
  const RegItemCard({super.key});
  @override
  Widget build(BuildContext context) {
    return   Container(
      color:Theme.of(context).cardColor,
            padding: const EdgeInsets.only(left:48.0, right:48, top:10, bottom:10),
      child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(left:15.0),
              child: Container(
                padding: EdgeInsets.only(left:15  ),
                width: 140,
                child: Text("Something")),
            ),
            Expanded(
              child: Container(
                width:230, child: Padding(
                  padding: const EdgeInsets.only(left:48.0),
                  child: Row(
                    children: [
                      Text("Something else"),
                      TextButton(onPressed: (){}, child: Icon(Icons.copy))
                    ],
                  ),
                )),
            ),
            SizedBox(width:150,child: Center(child: Text("6/8/2022 11:43"))),
            SizedBox(width:150,child: Center(child: ElevatedButton(onPressed: (){}, child: Text("Edit")))),
          ],
        ),
    ) ;
  }
}