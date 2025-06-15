import 'package:Homebase/utils/reusable.dart';
import 'package:Homebase/widgets/transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../entities/token.dart';
import 'initiative.dart';

class TokenAssets extends StatefulWidget {
  final Org org;
  int status = 0;
  TokenAssets({super.key, required this.org});

  @override
  State<TokenAssets> createState() => _TokenAssetsState();
}

class _TokenAssetsState extends State<TokenAssets> {
  List<TableRow> fungibleAssets = [];

  Future<void> buildAssets() async {
    fungibleAssets.clear();

    debugPrint("Adding native token ${widget.org.native.name}");
    fungibleAssets.add(
      asset(widget.org.native, widget.org.nativeBalance),
    );
  
    for (Token t in widget.org.erc20Tokens) {
      final bal = widget.org.treasury[t] ?? "0";
      debugPrint("Adding ERC20 token: ${t.name}, balance: $bal");
      fungibleAssets.add(asset(t, bal));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.org.populateTreasury(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 100,
              child: const Center(
                child: SizedBox(height: 4, child: LinearProgressIndicator()),
              ),
            ),
          );
        }
        debugPrint("populateTreasury() done, building assets...");
        buildAssets(); // We can call this synchronously now that data is ready

        return Card(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28.0, left: 9, right: 9),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 50),
                        width: 500,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(width: 0.1),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Find token by name or address',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.only(right: 50),
                        height: 40,
                        child: ToggleSwitch(
                          initialLabelIndex: widget.status,
                          totalSwitches: 2,
                          minWidth: 120,
                          borderWidth: 1.5,
                          activeFgColor: Theme.of(context).indicatorColor,
                          inactiveFgColor:
                              const Color.fromARGB(255, 189, 189, 189),
                          activeBgColor: const [
                            Color.fromARGB(255, 77, 77, 77)
                          ],
                          inactiveBgColor: Theme.of(context).cardColor,
                          borderColor: [Theme.of(context).cardColor],
                          labels: const ['Tokens', 'NFTs'],
                          onToggle: (index) {
                            debugPrint('Switched to: $index');
                            setState(() {
                              widget.status = index ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Show table if status == 0, else show NFT
                widget.status == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Table(
                            border: TableBorder.all(color: Colors.transparent),
                            columnWidths: const {
                              0: FlexColumnWidth(1.8),
                              1: FlexColumnWidth(0.3),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(1.4),
                              4: FixedColumnWidth(150),
                            },
                            children: const [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 4.0, left: 75),
                                    child: Text(
                                      "TOKEN NAME",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100),
                                    ),
                                  ),
                                  Center(child: Text("SYMBOL")),
                                  Center(child: Text("AMOUNT")),
                                  Center(child: Text("ADDRESS")),
                                  SizedBox(),
                                ],
                              ),
                            ],
                          ),
                          const Opacity(
                            opacity: 0.5,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 29.0),
                              child: Divider(),
                            ),
                          ),
                          Table(
                            border: TableBorder.all(color: Colors.transparent),
                            columnWidths: const {
                              0: FlexColumnWidth(1.8),
                              1: FlexColumnWidth(0.3),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(1.4),
                              4: FixedColumnWidth(150),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: fungibleAssets,
                          ),
                        ],
                      )
                    : const Center(
                        child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 58.0),
                        child: Text("No NFTs here",
                            style: TextStyle(fontSize: 20, color: Colors.grey)),
                      )

                        // Eneftee(
                        //   nft: NFT(
                        //     address: "0xdaf328d1720954612898u29d8h2398dh9238ds",
                        //     tokenId: 1,
                        //   ),
                        // ),
                        ),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow asset(Token token, String value) {
    final decimals = token.decimals ?? 0;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 75),
          child: Text(
            token.name,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Text(
              token.symbol,
              style: TextStyle(
                  color: Theme.of(context).indicatorColor, fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Text(
              displayTokenValue(value, decimals),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                token.address == 'native'
                    ? "native token"
                    : getShortAddress(token.address ?? ""),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token.address!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                          child: Text('Copied token address to clipboard')),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.white60,
              elevation: 0.1,
              backgroundColor: Theme.of(context).cardColor.withOpacity(0.9),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Proposal p = Proposal(org: widget.org);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Text("Transfer Assets"),
                      ),
                      content: Initiative(org: widget.org));
                },
              );
            },
            child: const Text("Transfer",
                style: TextStyle(fontSize: 13, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
