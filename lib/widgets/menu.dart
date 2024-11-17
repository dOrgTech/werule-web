import 'package:Homebase/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../entities/human.dart';
import '../screens/dao.dart';
import '../screens/explorer.dart';
import '../utils/functions.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

bool isConnected = false;
String us3rAddress = generateWalletAddress();
int status = 0;

class TopMenu extends StatefulWidget with PreferredSizeWidget {
  const TopMenu({super.key});

  @override
  State<TopMenu> createState() => _TopMenuState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _TopMenuState extends State<TopMenu> {
  final List<String> items = ['  Etherlink-Testnet', '  Etherlink-Mainnet'];

  // The current selected value of the dropdown
  String? selectedValue = '  Etherlink-Testnet';
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
          elevation: 1,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 12),
              Container(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Explorer()),
                  ),
                  child: Row(
                    children: [
                      // Image.network(
                      //   "https://i.ibb.co/7g5Dng6/trcom-dark.png", height: 40,
                      //   // SvgPicture.asset(
                      //   //   'assets/logos/homebase_logo.svg',
                      //   //   semanticsLabel: 'Acme Logo', height: 25,
                      //   //   color: Theme.of(context).indicatorColor,
                      //   //   // color: Colors.red,
                      // ),
                      // SizedBox(width: 10),
                      Image.network(
                        // "https://i.ibb.co/2dw4bZg/werule-mic-dark.png",
                        // "https://i.ibb.co/rsZc9mt/werule-allwhite.png",
                        "https://i.ibb.co/XXZRs8D/werule-white.png",
                        height: 26,
                        // SvgPicture.asset(
                        //   'assets/logos/homebase_logo.svg',
                        //   semanticsLabel: 'Acme Logo', height: 25,
                        //   color: Theme.of(context).indicatorColor,
                        //   // color: Colors.red,
                      ),
                      // SizedBox(width: 10),
                      // const Text(
                      //   'WeRule.io',
                      //   style: TextStyle(
                      //       fontFamily: 'CascadiaCode',
                      //       fontSize: 27,
                      //       fontWeight: FontWeight.w100),
                      // ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 24),
                child: Row(
                  children: [
                    SizedBox(
                        height: 38,
                        width: 38,
                        child: TextButton(
                          onPressed: () {
                            launch("https://discord.gg/XufcBNu277");
                          },
                          child: Image.network(
                            "https://i.ibb.co/Nr7Psjm/discord.png",
                            color: Color.fromARGB(255, 196, 196, 196),
                          ),
                        )),
                    SizedBox(
                      height: 38,
                      width: 38,
                      child:
                          TextButton(child: Icon(Icons.info), onPressed: () {}),
                    )
                  ],
                ),
              ),
              Spacer(),
              Container(
                  height: 49,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.1, color: Theme.of(context).indicatorColor),
                      color:
                          Theme.of(context).indicatorColor.withOpacity(0.05)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.connect_without_contact_sharp,
                        size: 29,
                        color:
                            Theme.of(context).indicatorColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Human().chain.name,
                        style: GoogleFonts.changa(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.7),
                            fontSize: 19),
                      )
                    ],
                  )),
              const SizedBox(width: 20),
              const Padding(
                padding: EdgeInsets.only(top: 1.0, right: 15),
                child: WalletBTN(),
              )
            ],
          ),
          // actions: <Widget>[

          // ],
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
