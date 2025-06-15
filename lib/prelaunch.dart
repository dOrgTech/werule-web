// import 'dart:convert';
// import 'dart:ui';
// import 'dart:math';
// import 'dart:async';
// import 'entities/human.dart';
// import 'screens/explorer.dart';
// import 'package:http/http.dart' as http;
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:universal_html/html.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webviewx/webviewx.dart';

// import 'main.dart';

// int caree = 1;
// String col = "#7b8c94 9%, #9cb1b8 46%, #7f9191 66%, #63767d 96%";
// List<Color> colors = [const Color(0xff7b8c94), const Color(0xff9cb1b8)];
// List<double> stops = [0.0, 0.8];
// List<Color> colors1 = [
//   Color.fromARGB(228, 97, 90, 90),
//   Color.fromARGB(228, 94, 87, 87),
//   Color.fromARGB(228, 87, 81, 81),
//   Color.fromARGB(228, 76, 72, 72),
//   Color.fromARGB(228, 71, 70, 75)
// ];
// List<double> stops1 = [0.0, 0.3, 0.6, 0.8, 0.9];

// class Prelaunch extends StatefulWidget {
//   Prelaunch({Key? key, }) : super(key: key);
//   bool loading = false;
//   bool sevede0 = false;
//   bool sevede1 = false;
//   bool sevede2 = false;
//   bool requesting = false;
//   bool requested = false;
//   bool captcha = false;
  
//   String email = "";
//   String ethaddress = "";
//   String message = "";
//   @override
//   State<Prelaunch> createState() => _PrelaunchState();
// }

// class _PrelaunchState extends State<Prelaunch> {
//   late WebViewXController webviewController;
//   @override
//   void initState() {
//     Future.delayed(const Duration(milliseconds: 440), () {
//       setState(() {
//         widget.sevede0 = true;
//       });
//     });
//     Future.delayed(const Duration(seconds: 3), () {
//       setState(() {
//         widget.sevede1 = true;
//       });
//     });
//     Future.delayed(const Duration(milliseconds: 3400), () {
//       setState(() {
//         widget.sevede2 = true;
//       });
//     });

//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black,
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Stack(
//           children: [
//             Container(
//                 height: MediaQuery.of(context).size.height,
//                 width: MediaQuery.of(context).size.width,
//                 color: Colors.black,
//                 child: const Text("o", style: TextStyle(color: Colors.black))),
//             //  Lottie.asset("images/gol.json"),

//             Positioned(
//                 right: 0,
//                 child: SizedBox(
//                     height: MediaQuery.of(context).size.height,
//                     child: FittedBox(
//                         fit: BoxFit.fitHeight,
//                         child: Opacity(opacity: 1, child: AnimatedImages())))),
//             Padding(
//               padding: EdgeInsets.only(
//                 right: MediaQuery.of(context).size.width / 4,
//               ),
//               child: Align(
//                   alignment: Alignment.topRight,
//                   child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       height: widget.sevede0
//                           ? MediaQuery.of(context).size.height
//                           : 0,
//                       width: widget.requesting ? 600 : 480,
//                       decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: colors1,
//                         stops: stops1,
//                       )),
//                       // color:Color.fromARGB(255, 27, 27, 27),
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         child: widget.requesting ? form() : splash(),
//                       ))),
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.only(right: MediaQuery.of(context).size.width / 4),
//               child: Align(
//                 alignment: Alignment.bottomRight,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     SizedBox(
//                         height: 34,
//                         width: 34,
//                         child: TextButton(
//                           onPressed: () {
//                             launch("https://github.com/dorgtech");
//                           },
//                           child: Image.network(
//                             "https://i.ibb.co/qWf3xck/github.png",
//                             color: Color.fromARGB(255, 196, 196, 196),
//                           ),
//                         )),
//                     SizedBox(
//                         height: 34,
//                         width: 34,
//                         child: TextButton(
//                           onPressed: () {
//                             launch("https://discord.gg/DtdHV2wWqt");
//                           },
//                           child: Image.network(
//                             "https://i.ibb.co/Nr7Psjm/discord.png",
//                             color: Color.fromARGB(255, 196, 196, 196),
//                           ),
//                         )),
//                     SizedBox(
//                         height: 34,
//                         width: 34,
//                         child: TextButton(
//                           onPressed: () {
//                             launch("https://twitter.com/dorg_tech");
//                           },
//                           child: Image.network(
//                             "https://i.ibb.co/sR4CWcJ/twitter-solid.png",
//                             color: Color.fromARGB(255, 196, 196, 196),
//                           ),
//                         )),
//                     const SizedBox(width: 20),
//                     SizedBox(
//                       height: 32,
//                       child: Center(
//                         child: Text(
//                           "dOrg © ${DateTime.now().year}",
//                           style: const TextStyle(
//                               fontSize: 9, color: Colors.white60),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 150),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   form() {
//     return SizedBox(
//       width: 400,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Request beta access",
//             style: GoogleFonts.pressStart2p(
//               fontSize: 16,
//               fontWeight: FontWeight.w900,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(
//             height: 150,
//           ),
//           TextField(
//             onChanged: (value) {
//               setState(() {
//                 widget.ethaddress = value;
//               });
//             },
//             style: const TextStyle(color: Colors.white),
//             decoration: const InputDecoration(
//               labelText: 'Your TEZ address',
//               labelStyle: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           TextField(
//             onChanged: (value) {
//               setState(() {
//                 widget.message = value;
//               });
//             },
//             maxLines: 3,
//             style: const TextStyle(color: Colors.white),
//             decoration: const InputDecoration(
//               labelText: "How would you use this please?",
//               labelStyle: TextStyle(
//                   color: Colors.white, textBaseline: TextBaseline.ideographic),
//             ),
//           ),
//           const SizedBox(
//             height: 90,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               TextButton(
//                 style: ButtonStyle(
//                     // elevation: MaterialStateProperty.all(0.4),
//                     ),
//                 child: SizedBox(
//                   height: 38,
//                   width: 100,
//                   child: Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.arrow_back),
//                         Text(
//                           '  Back',
//                           style: TextStyle(
//                               fontFamily: 'Ubuntu Mono',
//                               fontSize: 18,
//                               color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     widget.requesting = false;
//                   });
//                 },
//               ),
//               const Spacer(),
//               TextButton(
//                 style: ButtonStyle(
//                   elevation: MaterialStateProperty.all(0.4),
//                 ),
//                 child: SizedBox(
//                   height: 38,
//                   width: 100,
//                   child: Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.send_rounded),
//                         Text(
//                           '  SEND',
//                           style: TextStyle(
//                               fontFamily: 'Ubuntu Mono',
//                               fontSize: 18,
//                               color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 onPressed: widget.email.length > 3 &&
//                         widget.ethaddress.length > 3 &&
//                         widget.message.length > 3
//                     ? () async {
//                         String message = "New messaage on dorg.ml: \n\nemail " +
//                             widget.email +
//                             "\n" +
//                             "ETH address: " +
//                             widget.ethaddress +
//                             "\n" +
//                             "Message: " +
//                             widget.message +
//                             "\n-------------------";
//                         // await send(message);
//                         await sendfb();
//                       }
//                     : null,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   final interestedRef = null;
//   String webhook =
//       "https://discord.com/api/webhooks/993530794788270080/lZlmlVgnlgMnfZegKEfhYYh1FKj5kFxTP9FID9OHMZlXAfJJV-1fJIcc-GLuJ5TVaL8B";

//   sendfb() async {
//     await interestedRef.add({
//       "email": widget.email,
//       "ethaddress": widget.ethaddress,
//       "message": widget.message,
//       "date": DateTime.now().toString()
//     });
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: Container(
//           height: 50,
//           alignment: Alignment.topRight,
//           child:
//               const Center(child: Text("Thanks! We'll get back to you soon.")),
//         ),
//       ),
//     );
//     setState(() {
//       widget.requested = true;
//       widget.requesting = false;
//     });
//   }

//   send(message) async {
//     var content = {"content": message};
//     var headers = {"content-type": "application/json"};
//     var uri = Uri.parse(webhook);
//     var resp =
//         await http.post(uri, body: json.encode(content), headers: headers);
//     print(resp.toString());
//     setState(() {
//       widget.requested = true;
//       widget.requesting = false;
//     });
//   }

//   splash() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         const SizedBox(
//           height: 1,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 18.0),
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 18.0),
//               child: SizedBox(
//                 height: 230,
//                 child: TyperAnimatedTextKit(
//                   isRepeatingAnimation: false,
//                   pause: const Duration(seconds: 4),
//                   textAlign: TextAlign.center,
//                   speed: const Duration(milliseconds: 31),
//                   text: const ["TRUSTLESS \nBUSINESS \nECOSYSTEM"],
//                   textStyle: GoogleFonts.pressStart2p(
//                       height: 1.5,
//                       color: const Color.fromARGB(255, 196, 196, 196),
//                       fontSize: 23),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 11,
//         ),
//         AnimatedOpacity(
//           duration: const Duration(seconds: 1),
//           opacity: widget.sevede1 ? 1.0 : 0,
//           curve: Curves.easeIn,
//           child: TextButton(
//             onPressed: () => showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                       contentPadding: const EdgeInsets.all(0),
//                       content: Container(
//                           width: MediaQuery.of(context).size.width * 0.7,
//                           child: Container(
//                               color: Colors.blue,
//                               child: Text("SOMETHING HERE"))),
//                     )),
//             child: Text(
//               "WATCH VIDEO",
//               style: GoogleFonts.pressStart2p(
//                   height: 1.5,
//                   color: const Color.fromARGB(255, 196, 196, 196),
//                   fontSize: 15),
//             ),
//           ),
//         ),
//         widget.requested
//             ? const Text(" ")
//             : AnimatedOpacity(
//                 duration: const Duration(seconds: 1),
//                 opacity: widget.sevede2 ? 1.0 : 0,
//                 curve: Curves.easeIn,
//                 child: TextButton(
//                   onPressed: () {
//                     setState(() {
//                       widget.requesting = !widget.requesting;
//                     });
//                   },
//                   child: Text(
//                     "REQUEST BETA ACCESS",
//                     style: GoogleFonts.pressStart2p(
//                         height: 1.5,
//                         color: const Color.fromARGB(255, 196, 196, 196),
//                         fontSize: 15),
//                   ),
//                 ),
//               ),
//         const SizedBox(
//           height: 11,
//         ),
//         Consumer(builder: (context, watch, child) {
//           final om = null;
//           return SizedBox(
//             width: 160,
//             height: 33,
//             child: widget.loading
//                 ? const Center(
//                     child:
//                         SizedBox(height: 3, child: LinearProgressIndicator()),
//                   )
//                 : TextButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(
//                           const Color.fromARGB(204, 0, 0, 0)),
//                     ),
//                     onPressed: () async {
//                      Navigator.of(context).push(
//                       MaterialPageRoute(builder: ((context) => Scaffold(body:Explorer()))
//                      ));
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Placeholder(
//                           color: Colors.grey,
//                           child: SizedBox(height: 24),
//                         ),
//                         const Text("  MEMBERS",
//                             style: TextStyle(
//                               color: Color.fromARGB(255, 145, 145, 145),
//                             )),
//                       ],
//                     )),
//           );
//         })
//       ],
//     );
//   }

//   sainin(om) async {
//     print("Signing into the thing");
//     if (om.metamask) {
//       setState(() {
//         widget.loading = true;
//       });
//       String sainin = await om.signIn("andsaihdihaiduharei", context);
//       print("sainin $sainin");
//       if (sainin == "norep") {
//         setState(() {
//           widget.loading = false;
//         });
//         showDialog(
//             context: context,
//             builder: (context) => const AlertDialog(
//                   contentPadding: EdgeInsets.all(0),
//                   content: SizedBox(
//                       width: 400,
//                       height: 100,
//                       child: Center(
//                           child: Text(
//                               "You don't have any dOrg rep tokens on this account."))),
//                 ));
//       }
//       setState(() {
//         widget.loading = false;
//       });
//     } else {
//       showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               content: Container(
//                 height: 240,
//                 padding: const EdgeInsets.all(30),
//                 child: Column(
//                   children: [
//                     const Text(
//                       "You need the Metamask wallet to sign into d0rg.",
//                       style: TextStyle(fontFamily: "OCR-A", fontSize: 16),
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Placeholder(
//                           color: Colors.grey,
//                           child: SizedBox(width: 100),
//                         ),
//                         const Icon(
//                           Icons.arrow_right_alt,
//                           size: 40,
//                         ),
//                         const SizedBox(
//                           width: 14,
//                         ),
//                         Placeholder(
//                           color: Colors.grey,
//                           child: SizedBox(height: 100),
//                         ),
//                         const SizedBox(
//                           width: 13,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           "Download it from ",
//                           style: TextStyle(fontFamily: "OCR-A", fontSize: 16),
//                         ),
//                         TextButton(
//                             onPressed: () {
//                               launch("https://metamask.io/");
//                             },
//                             child: const Text(
//                               "https://metamask.io/",
//                               style:
//                                   TextStyle(fontFamily: "OCR-A", fontSize: 16),
//                             )),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           });
//     }
//   }
// }

// class Pattern extends StatelessWidget {
//   late WebViewXController webviewController;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: Image.asset("assets/doar.png"),
//     );
//   }
// }

// class AnimatedImages extends StatefulWidget {
//   @override
//   _AnimatedImagesState createState() => _AnimatedImagesState();
// }

// class _AnimatedImagesState extends State<AnimatedImages>
//     with TickerProviderStateMixin {
//   late AnimationController controller1;
//   late AnimationController controller2;
//   late AnimationController controller3;
//   late AnimationController flickerController;
//   late AnimationController blurController;
//   late AnimationController translationController;
//   late Animation<Offset> animation;
//   final random = Random();
//   Offset translation = Offset(0, 0);
//   @override
//   void initState() {
//     super.initState();
//     blurController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
//     translationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     animation = Tween<Offset>(
//       begin: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
//       end: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
//     ).animate(
//       CurvedAnimation(
//         parent: translationController,
//         curve: Curves.linear,
//       ),
//     )..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           translationController.reset();
//           animation = Tween<Offset>(
//             begin: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
//             end: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
//           ).animate(
//             CurvedAnimation(
//               parent: translationController,
//               curve: Curves.linear,
//             ),
//           );
//           translationController.forward();
//         }
//       });

//     translationController.forward();

//     controller1 = AnimationController(
//       duration: const Duration(seconds: 7),
//       vsync: this,
//     )..repeat(reverse: true);

//     controller2 = AnimationController(
//       duration: const Duration(seconds: 5),
//       vsync: this,
//     )..repeat(reverse: true);

//     controller3 = AnimationController(
//       duration: const Duration(seconds: 12),
//       vsync: this,
//     )..repeat(reverse: true);

//     flickerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     )
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           flickerController.reverse();
//         } else if (status == AnimationStatus.dismissed) {
//           flickerController.forward();
//         }
//       })
//       ..forward();
//   }

//   @override
//   void dispose() {
//     controller1.dispose();
//     controller2.dispose();
//     controller3.dispose();
//     flickerController.dispose();
//     blurController.dispose();
//     translationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           // buildAnimatedBlur(blurController),
//           alternate(),
//           Opacity(
//               opacity: 0.6,
//               child: Container(
//                 color: Colors.black,
//               )),
//           Opacity(
//               opacity: 0.1,
//               child:
//                   buildFlickeringImage(flickerController, 'assets/loop1.gif')),
//         ],
//       ),
//     );
//   }

//   Widget smaller(Widget bigger) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 900,
//         height: 900,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             widget,
//             SizedBox(
//               width: 400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildAnimatedImage(AnimationController controller, String asset) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (BuildContext context, Widget? child) {
//         return Opacity(
//           opacity: controller.value,
//           child: FittedBox(
//             fit: BoxFit.cover,
//             child: Padding(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).size.height / 2,
//                 bottom: MediaQuery.of(context).size.height / 2,
//                 right: MediaQuery.of(context).size.width / 4,
//                 left: MediaQuery.of(context).size.width / 6,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(80.0),
//                 child: Image.asset(
//                   asset,
//                   height: 340,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget alternate() {
//     return FittedBox(
//       fit: BoxFit.cover,
//       child: Padding(
//           padding: EdgeInsets.all(200),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset("assets/loop2.gif"),
//               SizedBox(
//                 width: 500,
//               )
//             ],
//           )),
//     );
//   }

//   Widget buildAnimatedBlur(AnimationController controller) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([controller, animation]),
//       builder: (BuildContext context, Widget? child) {
//         return FractionalTranslation(
//           translation: animation.value,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 4.4, sigmaY: 2),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.7,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         Colors.transparent,
//                         Colors.transparent,
//                         Colors.white.withOpacity(0.0)
//                       ],
//                       stops: [0.0, 0.1, 0.9],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildFlickeringImage(AnimationController controller, String asset) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (BuildContext context, Widget? child) {
//         return Transform(
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, 0.001) // perspective
//             ..rotateX(0.05 * controller.value)
//             ..rotateY(0.04 * controller.value),
//           alignment: FractionalOffset.center,
//           child: Opacity(
//             opacity: 0.3 +
//                 random.nextDouble() *
//                     0.12, // Random opacity between 0.5 and 1.0
//             child: ColorFiltered(
//               colorFilter: ColorFilter.mode(
//                   Colors.white.withOpacity(0.2 * controller.value),
//                   BlendMode.softLight), // Increase brightness
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: MediaQuery.of(context).size.height / 2,
//                     right: MediaQuery.of(context).size.width / 4,
//                     bottom: MediaQuery.of(context).size.height / 2,
//                   ),
//                   child: Image.asset(
//                     asset,
//                     height: 400,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
