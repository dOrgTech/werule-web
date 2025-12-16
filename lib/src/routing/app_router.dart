// lib/src/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_creator/dao_creator_screen.dart';
import 'package:werule/src/features/dao_detail/dao_detail_screen.dart';
import 'package:werule/src/features/debate_detail/debate_detail_screen.dart';
import 'package:werule/src/features/explorer/explorer_screen.dart';
import 'package:werule/src/features/proposal_detail/proposal_detail_screen.dart';
import 'package:werule/src/providers/network_provider.dart';

// A reusable fade transition builder for all routes.
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
      pageBuilder: (context, state) {
        final networkName = state.pathParameters['networkName']!;
        return _buildFadeTransitionPage(
          context: context,
          state: state,
          child:
              ExplorerScreen(key: ValueKey(networkName), networkName: networkName),
        );
      },
      routes: [
        // THE FIX: Added the DAO creator route.
        GoRoute(
          path: 'create',
          pageBuilder: (context, state) {
            final networkName = state.pathParameters['networkName']!;
            return _buildFadeTransitionPage(
              context: context,
              state: state,
              child: DaoCreatorScreen(networkName: networkName),
            );
          },
        ),
        // DAO Detail route: '/:networkName/:daoAddress'
        GoRoute(
          path: ':daoAddress',
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
            // Debate Detail route: '/:networkName/:daoAddress/debates/:debateAddress'
            GoRoute(
              path: 'debates/:debateAddress',
              pageBuilder: (context, state) {
                final networkName = state.pathParameters['networkName']!;
                final daoAddress = state.pathParameters['daoAddress']!;
                final debateAddress = state.pathParameters['debateAddress']!;
                return _buildFadeTransitionPage(
                  context: context,
                  state: state,
                  child: DebateDetailScreen(
                    networkName: networkName,
                    daoAddress: daoAddress,
                    debateAddress: debateAddress,
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