import 'package:flutter/material.dart';

class HoverExpandWidget extends StatefulWidget {
  @override
  _HoverExpandWidgetState createState() => _HoverExpandWidgetState();
}
int? _hoveredIndex;

class _HoverExpandWidgetState extends State<HoverExpandWidget>
    with TickerProviderStateMixin {
  late final OverlayEntry _overlayEntry;
  final GlobalKey _key = GlobalKey();
  late AnimationController _controller;
  late AnimationController _fadeOutController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 230),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeInOut,
      ),
    );

    _sizeAnimation = Tween<double>(begin: 100.0, end: 300.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _widthAnimation = Tween<double>(begin: 120.0, end: 300.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _fadeOutController.reset();
        _overlayEntry.remove();
      }
    });

    _overlayEntry = OverlayEntry(builder: _overlayBuilder);
  }

  Widget _overlayBuilder(BuildContext context) {
    final RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    final options = [
      ["Open to proposals", "Post a definition of your wanted deliverable."],
      ["Set parties", "Formalize an existing agreement"],
      ["Import project", "from legacy justice providers."],
    ];

    return Positioned(
      top: position.dy,
      right: MediaQuery.of(context).size.width - position.dx - 120.0, 
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: MouseRegion(
            onExit: (_) {
              _fadeOutController.reset();
              _controller.reverse();
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    
                    border: Border.all(
                      
                      color: Theme.of(context).cardColor, width: 0.5),
                   color: Color.lerp(
          Color.fromARGB(255, 49, 172, 168).withOpacity(1.0), 
          Theme.of(context).canvasColor.withOpacity(0.95), 
          _controller.value,
        ),
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                        offset: Offset(0.0, 4.0),
                      ),
                    ],
                  ),
                  width: _widthAnimation.value,
                  height: _sizeAnimation.value,
                  child: _controller.status == AnimationStatus.completed
                      ? FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Interval(0.7, 1.0, curve: Curves.easeIn),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 8.0),
                              Text(
                                "New Project",
                                style: TextStyle(
                                  color: Theme.of(context).indicatorColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Divider(color: Theme.of(context).indicatorColor, thickness: 1),
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    return TextButton(
                                      onPressed: () async {
                                        print('${options[index][0]} clicked');
                                        await _fadeOutController.forward();
                                        _controller.reverse();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              options[index][0],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w100,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              options[index][1],
                                              style: TextStyle(
                                                color: Theme.of(context).indicatorColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        Overlay.of(context).insert(_overlayEntry);
        _controller.forward();
      },
      child: Container(
        key: _key,
        decoration: BoxDecoration(
          color: Theme.of(context).indicatorColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        height: 40.0,
        width: 120.0,
        child: Center(
          child: Text(
            'New Project',
            style: const TextStyle(color: Colors.black, fontSize: 19),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }
}