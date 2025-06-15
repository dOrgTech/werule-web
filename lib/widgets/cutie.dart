import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class Cutie extends StatefulWidget {
  String? title;
  String? desc;
  List? treburi;
  Cutie({super.key, this.title, this.desc, this.treburi});
  @override
  _CutieState createState() => _CutieState();
}

class _CutieState extends State<Cutie> {
  final int _counter = 0;
  // double pos = 300;
  double inal = 150;
  Widget? inceput;
  Widget? sfarsit;
  double? inaltime;
  @override
  void initState() {
    inaltime = (50 + ((widget.treburi!.length) * 90)).toDouble();
    inceput = Container(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 27),
            child: Text(
              widget.title!,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            )),
        const Text(
          "",
        ),
        Container(
            height: 57,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
                child: Text(
              widget.desc!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ))),
      ],
    ));

    List<Widget> butoane =  [];
    butoane.add(Container(
      padding: const EdgeInsets.only(top: 27),
      child: Center(
        child: Text(
          widget.title!,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    ));
    butoane.add(const SizedBox(height: 33));
    for (int i = 0; i < widget.treburi!.length; i++) {
      butoane.add(item(widget.treburi![i][0], widget.treburi![i][1],
          widget.treburi![i][2], widget.treburi![i][3]));
      butoane.add(const SizedBox(
        height: 7,
      ));
    }
    sfarsit = Container(
      child: Column(
        children: butoane,
      ),
    );
    super.initState();
  }

  expandBox(PointerEvent details) {
    setState(() {
      inal = widget.title! == "NODE SETUP"
          ? 180
          : widget.title! == "PROJECTS"
              ? 330
              : widget.title == "ORGANIZATION"
                  ? 420
                  : inaltime!;
      inceput = sfarsit;
    });
  }

  expand() {
    setState(() {
      inal = widget.title == "NODE SETUP"
          ? 280
          : widget.title == "ROADMAP"
              ? 340
              : inaltime!;
      inceput = sfarsit;
    });
  }

  compactBox(PointerEvent details) {
    setState(() {
      inal = 150;
      inceput = Container(
          child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 27),
              child: Text(
                widget.title!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              )),
          const Text(
            "",
          ),
          Container(
              height: 57,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Text(
                widget.desc!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ))),
        ],
      ));
    });
  }
  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget item(titlu, desc, key, route) {
    return TextButton(
        onPressed: () {
          route == "/viratrace"
              ? launchURL("https://www.viratrace.org")
              : route == "/afterme"
                  ? launchURL("https://afterme.tk")
                  : Navigator.of(context).pushNamed(route, arguments: key);
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titlu,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                      fontWeight: FontWeight.w200, color: Colors.white70),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          // top: pos,
          child: MouseRegion(
              onHover: expandBox,
              onExit: compactBox,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: Colors.white70),
                    color: Colors.black45,
                  ),
                  height: inal,
                  width: 180,
                  child: GestureDetector(
                    onTap: expand,
                    child: Center(child: inceput),
                  ))))
    ]);
  }
}