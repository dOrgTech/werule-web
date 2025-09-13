// lib/src/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/dao_detail_screen.dart';
import 'package:werule/src/features/explorer/explorer_screen.dart';
import 'package:werule/src/features/proposal_detail/proposal_detail_screen.dart';
import 'package:werule/src/providers/network_provider.dart';

// GoRouter configuration
final appRouter = GoRouter(
  routes: [
    // Root route: '/'
    GoRoute(
      path: '/',
      builder: (context, state) => const ExplorerScreen(),
      redirect: (context, state) {
        final networkProvider = context.read<NetworkProvider>();

        // THE FIX: The redirect logic is now smarter.
        // Priority 1: If a network is already selected, redirect to its explorer page.
        // This maintains the state when navigating back to the home screen.
        if (networkProvider.selectedNetwork != null) {
          return '/${networkProvider.selectedNetwork!.name}';
        }

        // Priority 2 (Fallback): If no network is selected yet (on initial app load),
        // use the default network.
        if (networkProvider.defaultNetwork != null) {
          return '/${networkProvider.defaultNetwork!.name}';
        }

        // If networks haven't loaded at all, don't redirect yet.
        return null;
      },
    ),
    // DAO Explorer route: '/:networkName'
    GoRoute(
      path: '/:networkName',
      builder: (context, state) {
        final networkName = state.pathParameters['networkName']!;
        return ExplorerScreen(key: ValueKey(networkName), networkName: networkName);
      },
      routes: [
        // DAO Detail route: '/:networkName/:daoAddress'
        GoRoute(
          path: ':daoAddress',
          builder: (context, state) {
            final networkName = state.pathParameters['networkName']!;
            final daoAddress = state.pathParameters['daoAddress']!;
            return DaoDetailScreen(
              key: ValueKey('$networkName-$daoAddress'),
              networkName: networkName,
              daoAddress: daoAddress,
            );
          },
          routes: [
            // Proposal Detail route: '/:networkName/:daoAddress/proposals/:proposalId'
            GoRoute(
              path: 'proposals/:proposalId',
              builder: (context, state) {
                final networkName = state.pathParameters['networkName']!;
                final daoAddress = state.pathParameters['daoAddress']!;
                final proposalId = state.pathParameters['proposalId']!;
                return ProposalDetailScreen(
                  networkName: networkName,
                  daoAddress: daoAddress,
                  proposalId: proposalId,
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