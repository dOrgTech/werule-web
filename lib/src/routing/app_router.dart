// lib/src/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/dao_detail_screen.dart';
import 'package:werule/src/features/explorer/explorer_screen.dart';
import 'package:werule/src/features/proposal_detail/proposal_detail_screen.dart';
import 'package:werule/src/providers/network_provider.dart';

// THE FIX: A reusable fade transition builder for all routes.
CustomTransitionPage<T> _buildFadeTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 500),
  );
}

// GoRouter configuration
final appRouter = GoRouter(
  routes: [
    // Root route: '/'
    GoRoute(
      path: '/',
      // THE FIX: Use pageBuilder to apply the custom transition.
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        context: context,
        state: state,
        child: const ExplorerScreen(),
      ),
      redirect: (context, state) {
        final networkProvider = context.read<NetworkProvider>();
        if (networkProvider.selectedNetwork != null) {
          return '/${networkProvider.selectedNetwork!.name}';
        }
        if (networkProvider.defaultNetwork != null) {
          return '/${networkProvider.defaultNetwork!.name}';
        }
        return null;
      },
    ),
    // DAO Explorer route: '/:networkName'
    GoRoute(
      path: '/:networkName',
      // THE FIX: Use pageBuilder to apply the custom transition.
      pageBuilder: (context, state) {
        final networkName = state.pathParameters['networkName']!;
        return _buildFadeTransitionPage(
          context: context,
          state: state,
          child: ExplorerScreen(key: ValueKey(networkName), networkName: networkName),
        );
      },
      routes: [
        // DAO Detail route: '/:networkName/:daoAddress'
        GoRoute(
          path: ':daoAddress',
          // THE FIX: Use pageBuilder to apply the custom transition.
          pageBuilder: (context, state) {
            final networkName = state.pathParameters['networkName']!;
            final daoAddress = state.pathParameters['daoAddress']!;
            return _buildFadeTransitionPage(
              context: context,
              state: state,
              child: DaoDetailScreen(
                key: ValueKey('$networkName-$daoAddress'),
                networkName: networkName,
                daoAddress: daoAddress,
              ),
            );
          },
          routes: [
            // Proposal Detail route: '/:networkName/:daoAddress/proposals/:proposalId'
            GoRoute(
              path: 'proposals/:proposalId',
              // THE FIX: Use pageBuilder to apply the custom transition.
              pageBuilder: (context, state) {
                final networkName = state.pathParameters['networkName']!;
                final daoAddress = state.pathParameters['daoAddress']!;
                final proposalId = state.pathParameters['proposalId']!;
                return _buildFadeTransitionPage(
                  context: context,
                  state: state,
                  child: ProposalDetailScreen(
                    networkName: networkName,
                    daoAddress: daoAddress,
                    proposalId: proposalId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
// lib/src/routing/app_router.dart