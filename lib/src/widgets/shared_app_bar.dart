// lib/src/widgets/shared_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    // Use a LayoutBuilder to check the available width.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define a threshold for switching to mobile layout.
        final isMobile = constraints.maxWidth < 650;

        final titleWidget = InkWell(
          onTap: () => context.go('/'),
          child: const Text('WeRule DAO Explorer'),
        );

        final actionsRow = [
          NetworkSelector(isEnabled: isNetworkSelectorEnabled),
          const SizedBox(width: 8),
          const WalletConnector(),
        ];

        return AppBar(
          backgroundColor: const Color(0xff222222),
          elevation: 0,
          // Disable the automatic back button.
          automaticallyImplyLeading: false,
          // Use our custom leading widget if provided.
          leading: leading,
          // The title is now a constrained and centered row.
          title: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  titleWidget,
                  const Spacer(),
                  // On desktop, show actions directly in the AppBar.
                  if (!isMobile) ...actionsRow,
                ],
              ),
            ),
          ),
          actions: [
            // On mobile, show the hamburger menu icon.
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            // Add padding to the right for the hamburger menu.
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// A simple widget for the content of the mobile drawer.
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