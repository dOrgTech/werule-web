import 'package:Homebase/utils/functions.dart';
import 'package:Homebase/utils/reusable.dart';
import 'package:Homebase/widgets/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/org.dart';
import '../entities/proposal.dart';
import '../widgets/tokenAssets.dart';
import '../widgets/viewConfig.dart';


class Home extends StatefulWidget {
  Home({super.key, required this.org});
  Org org;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return widget.org.debatesOnly! ? debatesWide() : fullWide();
  }

  debatesWide() {
    int activeProposals = 0;
    int awaitingExecution = 0;
    for (Proposal p in widget.org.proposals) {
      if (p.status == "active") {
        activeProposals++;
      } else if (p.status == "executable") {
        awaitingExecution++;
      }
    }
    return ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
          height: 180,
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: FutureBuilder<Uint8List>(
                            future: generateAvatarAsync(hashString(widget.org
                                .address!)), // Make your generateAvatar function return Future<Uint8List>
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: 32.0,
                                  height: 32.0,
                                  color: Colors.grey,
                                );
                              } else if (snapshot.hasData) {
                                return Image.memory(snapshot.data!);
                              } else {
                                return Container(
                                  width: 32.0,
                                  height: 32.0,
                                  color: const Color.fromARGB(
                                    255, 116, 116, 116), // Error color
                                );
                              }
                            },
                          ),
                        ),
                      ),
  
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          widget.org.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                  width: 0.1,
                                  color: Theme.of(context).hintColor),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: ((context) => AlertDialog(
                                        content: ViewConfig(org: widget.org),
                                      )));
                            },
                            child: Opacity(
                              opacity: 0.7,
                              child: Icon(
                                Icons.settings,
                                color: Theme.of(context).indicatorColor,
                                size: 14,
                              ),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${widget.org.symbol} Token: "),
                          Text(
                           
                            widget.org.govTokenAddress!,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          TextButton(
                              onPressed: () {
                                //copy the address to clipboard
                                Clipboard.setData(ClipboardData(
                                    text: widget.org.govTokenAddress!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Center(
                                            child: Text(
                                                'Address copied to clipboard'))));
                              }, child: const Icon(Icons.copy)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                padding: const EdgeInsets.all(11.0),
                child: Text(
                  widget.org.description!,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Wrap(spacing: 20, runSpacing: 20, children: [
          metricBox(
              context,
              formatTotalSupply(widget.org.totalSupply!, widget.org.decimals!),
              "Total\nVoting\nPower"),
          metricBox(context, widget.org.holders.toString(), "Members"),
          metricBox(context, activeProposals, "Open\nDebates"),
          metricBox(context, widget.org.proposals.length, "Total\nDebates"),
        ]),
        const SizedBox(height: 25),
        // MemeArrowWidget()
        const SizedBox(
          width: 1200,
          height: 300,
          child: PlaylistWidget(playlist:
              // "https://d3fixynhjasvbt.cloudfront.net/k5kjs4%2Fpreview%2F64049024%2Fmain_large.gif?response-content-disposition=inline%3Bfilename%3D%22main_large.gif%22%3B&response-content-type=image%2Fgif&Expires=1738025751&Signature=Sxg5laL5ha4WEdDm6xuzu~VVFIJ3IyO4p6Hk6ljgXxD8XBHArb4Enui0EfMrY0IJiWwS-SPjtVqCHT2cEevvWAfDAmP1hFQ6un0tahcBe~bvr-E5ULDMAtUtcM3xeuN5OKnizzdSne0VxvNrHWF8ORPiKyArj9kFZwbLNeZVKMPm~gPXGsmzG7nkjBdL9~ww3jfNOPFWXYWJ4HW0VmfbvGAJMPO4bytLtVcPsPEm4DLX3syLD~9VEZypBVqF5SiPEv9jJiU0P9isndsNQrgBIxMjlus7KMfofy9CIBuWVSbh6I7Vf4J67TqREynSQ0zkE9JBCwWViYkkqOs9H7xA5w__&Key-Pair-Id=APKAJT5WQLLEOADKLHBQ"),
              {
            "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExYjJjbGZ3bXhhdWhtdGdlcWE5MmlkYmY1cWliaTZrZGNja2J1cG5waCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/o9LfO9cEdT7VbSRwr1/giphy.gif":
                9000,
            "https://i.ibb.co/NWV1QK2/peste1bun.gif": 8575,
            "https://i.ibb.co/dg1X4r3/peste2-ezgif-com-resize.gif": 14200,
            "https://i.ibb.co/NCQ5phC/rata-ezgif-com-optimize.gif": 9000
          }),
        )
      ],
    );
  }

  fullWide() {
    int activeProposals = 0;
    int awaitingExecution = 0;
    for (Proposal p in widget.org.proposals) {
      if (p.status == "active") {
        activeProposals++;
      } else if (p.status == "executable") {
        awaitingExecution++;
      }
    }
    return ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
          height: 180,
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: FutureBuilder<Uint8List>(
                            future: generateAvatarAsync(hashString(widget.org
                                .address!)), // Make your generateAvatar function return Future<Uint8List>
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: 32.0,
                                  height: 32.0,
                                  color: Colors.grey,
                                );
                              } else if (snapshot.hasData) {
                                return Image.memory(snapshot.data!);
                              } else {
                                return Container(
                                  width: 32.0,
                                  height: 32.0,
                                  color: const Color.fromARGB(
                                      255, 116, 116, 116), // Error color
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          widget.org.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                  width: 0.1,
                                  color: Theme.of(context).hintColor),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: ((context) => AlertDialog(
                                        content: ViewConfig(org: widget.org),
                                      )));
                            },
                            child: Opacity(
                              opacity: 0.7,
                              child: Icon(
                                Icons.settings,
                                color: Theme.of(context).indicatorColor,
                                size: 14,
                              ),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(" Treasury: "),
                          Text(
                            widget.org.registryAddress!
                            // "asiduhwqiudh128hd92w8h19q8dh9w8dh398dhd2938"
                            ,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          TextButton(
                              onPressed: () {
                                //copy the address to clipboard
                                Clipboard.setData(ClipboardData(
                                    text: widget.org.treasuryAddress!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Center(
                                            child: Text(
                                                'Address copied to clipboard'))));
                              },
                              child: const Icon(Icons.copy)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${widget.org.symbol} Token: "),
                          Text(
                            // "d2038jd028wjfoisfpjq3p9f8jpe398hfpsqhiw"
                            widget.org.govTokenAddress!,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          TextButton(
                              onPressed: () {
                                //copy the address to clipboard
                                Clipboard.setData(ClipboardData(
                                    text: widget.org.govTokenAddress!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Center(
                                            child: Text(
                                                'Address copied to clipboard'))));
                              }, child: const Icon(Icons.copy)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                padding: const EdgeInsets.all(11.0),
                child: Builder(builder: (context) {
                  print("[Home Widget] Displaying description. org.name: ${widget.org.name}, org.wrapped: '${widget.org.wrapped}', org.description: '${widget.org.description}'");
                  return Text(
                    widget.org.wrapped ?? widget.org.description!,
                    // widget.org.description!,
                    textAlign: TextAlign.center,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Wrap(spacing: 20, runSpacing: 20, children: [
          metricBox(
              context,
              formatTotalSupply(widget.org.totalSupply!, widget.org.decimals!),
              "Total\nVoting\nPower"),
          metricBox(context, widget.org.holders.toString(), "Members"),
          metricBox(context, activeProposals, "Active\nProposals"),
          metricBox(
              context, awaitingExecution, "Proposals \nAwaiting \nExecution"),
        ]),
        const SizedBox(height: 25),
        TokenAssets(org: widget.org)
      ],
    );
  }

  Widget metricBox(context, number, label) {
    return SizedBox(
      width: 285,
      height: 140,
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 55),
              child: Text(
                number.toString(),
                style: TextStyle(
                    color: Theme.of(context).indicatorColor,
                    fontSize: 27,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 39),
                child: Text(
                  label,
                  textAlign: TextAlign.left,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 16,
                    height:
                        1.5, // Adjust this value to control the vertical space
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
