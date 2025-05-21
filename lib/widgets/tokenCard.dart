import "package:flutter/material.dart";


class TokenCard extends StatelessWidget {
  const TokenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 230,
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(child: Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text("PEPE", style: TextStyle(color:Theme.of(context).indicatorColor, fontSize: 20)),
            )),
            Padding(
              padding: const EdgeInsets.only(left:28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
              Row(
                
                children: [
               const Text("KT1M...v8Z9"),
                TextButton(onPressed: (){}, child: const Icon(Icons.copy)),
              ],),

              const SizedBox(height: 31),
              const Text("Balance:"),
              const SizedBox(height: 11),
              const Text("259856478.13", style: TextStyle(fontSize: 19)),
                ],
              ),
            ),
            
            Center(
              child: ElevatedButton(
                onPressed: (){}, child: const Text("Transfer")),
            )
          ],
        ),
      ),
    
    );
  }
}