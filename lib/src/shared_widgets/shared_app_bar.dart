// lib/src/widgets/shared_app_bar.dart

import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_detail/widgets/footer.dart';
import 'package:werule/src/features/explorer/widgets/app_bar_widgets.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool isNetworkSelectorEnabled;

  const SharedAppBar({
    super.key,
    this.leading,
    this.isNetworkSelectorEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        const titleWidget = Brand();
        
        final actionsRow = [
          Padding(
            padding: const EdgeInsets.only (top:2.0),
            child: NetworkSelector(isEnabled: isNetworkSelectorEnabled),
          ),
          // THE FIX: Increased spacing between the buttons.
          const SizedBox(width: 22),
          const Padding(
            padding: EdgeInsets.only(top:2.0),
            child: WalletConnector(),
          ),
        ];

        return AppBar(
          backgroundColor: const Color(0xff222222),
          elevation: 0,
          toolbarHeight: 42,
          automaticallyImplyLeading: false,
          leading: leading,
          title: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only (left:22.0, top:2),
                    child: titleWidget,
                  ),
                  const Spacer(),
                  if (!isMobile) ...actionsRow,
                ],
              ),
            ),
          ),
          actions: [
            if (isMobile)
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            const SizedBox(width: 18),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44);
}

class MobileDrawer extends StatelessWidget {
  final bool isNetworkSelectorEnabled;
  const MobileDrawer({super.key, required this.isNetworkSelectorEnabled});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff222222),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            NetworkSelector(isEnabled: isNetworkSelectorEnabled),
            const SizedBox(height: 16),
            const WalletConnector(),
          ],
        ),
      ),
    );
  }
}
// lib/src/widgets/shared_app_bar.dart