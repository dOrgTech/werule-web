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
    // Redirects to the explorer with the default network's chain ID.
    GoRoute(
      path: '/',
      builder: (context, state) => const ExplorerScreen(),
      redirect: (context, state) {
        // Find the default network from the provider.
        final defaultNetwork = context.read<NetworkProvider>().defaultNetwork;
        // If a default network is found, redirect to its explorer page.
        if (defaultNetwork != null) {
          return '/${defaultNetwork.name}';
        }
        // If no networks are loaded yet, stay on the root to show a loading state.
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