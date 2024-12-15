import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegItemCard extends StatelessWidget {
  String itemKey;
  String itemValue;
  RegItemCard({
    super.key,
    required this.itemValue,
    required this.itemKey,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      color: Theme.of(context).cardColor,
      padding:
          const EdgeInsets.only(left: 48.0, right: 48, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Container(
                padding: EdgeInsets.only(left: 15),
                width: 140,
                child: Text(itemKey)),
          ),
          Expanded(
            child: Container(
                width: 230,
                child: Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Text(itemValue)),
                      TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: itemValue));
                          },
                          child: Icon(Icons.copy))
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
