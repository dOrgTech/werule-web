// lib/src/features/debate_detail/debate_detail_screen.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/debate_detail/widgets/add_argument_dialog.dart';
import 'package:werule/src/features/debate_detail/widgets/argument_card.dart';
import 'package:werule/src/models/debate.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/debates_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/shared_widgets/shared_app_bar.dart';
import 'package:werule/src/utils/reusable.dart';

/// Screen for viewing and interacting with a debate
class DebateDetailScreen extends StatefulWidget {
  final String networkName;
  final String daoAddress;
  final String debateAddress;

  const DebateDetailScreen({
    super.key,
    required this.networkName,
    required this.daoAddress,
    required this.debateAddress,
  });

  @override
  State<DebateDetailScreen> createState() => _DebateDetailScreenState();
}

class _DebateDetailScreenState extends State<DebateDetailScreen> {
  Org? _org;
  DebatesProvider? _debatesProvider;
  DebateArgument? _currentArgument;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      // Load DAO from Firestore
      final firestoreService = context.read<FirestoreService>();
      final collectionName = 'idaos${widget.networkName}';
      final org = await firestoreService.getDao(collectionName, widget.daoAddress);

      if (org == null) {
        setState(() {
          _initError = "DAO not found";
          _isInitializing = false;
        });
        return;
      }

      // Get network
      final network = context.read<NetworkProvider>().networks.firstWhereOrNull(
            (n) => n.name == widget.networkName,
          );

      if (network == null) {
        setState(() {
          _initError = "Network not found";
          _isInitializing = false;
        });
        return;
      }

      // Get debates factory address
      final debatesFactory = await firestoreService.getDebatesFactoryAddress(widget.networkName);
      if (debatesFactory == null || debatesFactory.isEmpty) {
        setState(() {
          _initError = "Debates not available on this network";
          _isInitializing = false;
        });
        return;
      }

      if (!mounted) return;

      // Create provider
      _org = org;
      _debatesProvider = DebatesProvider(
        blockchainService: context.read<BlockchainService>(),
        authProvider: context.read<AuthProvider>(),
        org: org,
        network: network,
        debatesFactoryAddress: debatesFactory,
      );

      // Load the debate
      await _debatesProvider!.loadDebate(widget.debateAddress);

      if (mounted) {
        setState(() {
          _isInitializing = false;
          if (_debatesProvider!.currentDebate?.rootArgument != null) {
            _currentArgument = _debatesProvider!.currentDebate!.rootArgument;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = "Failed to load debate: $e";
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debatesProvider?.dispose();
    super.dispose();
  }

  void _navigateToArgument(DebateArgument arg) {
    setState(() {
      _currentArgument = arg;
    });
  }

  void _navigateToParent() {
    if (_currentArgument?.parent != null) {
      setState(() {
        _currentArgument = _currentArgument!.parent;
      });
    }
  }

  void _showAddArgumentDialog(ArgumentType argType) {
    final auth = context.read<AuthProvider>();
    if (!auth.isConnected || auth.selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Please connect your wallet to add an argument.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: _debatesProvider!,
        child: AddArgumentDialog(
          debate: _debatesProvider!.currentDebate!,
          parentArgument: _currentArgument!,
          argType: argType,
          org: _org!,
          onSuccess: () {
            // Refresh and stay on current argument (or its equivalent after refresh)
            final currentId = _currentArgument?.id;
            _debatesProvider!.refreshCurrentDebate().then((_) {
              if (mounted && currentId != null) {
                // Find the argument with the same ID after refresh
                final debate = _debatesProvider!.currentDebate;
                if (debate != null) {
                  final arg = debate.arguments.firstWhere(
                    (a) => a.id == currentId,
                    orElse: () => debate.rootArgument!,
                  );
                  setState(() => _currentArgument = arg);
                }
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: const SharedAppBar(),
      endDrawer: const MobileDrawer(isNetworkSelectorEnabled: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_initError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_initError!, style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isInitializing = true;
                  _initError = null;
                });
                _initializeScreen();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_debatesProvider == null || _org == null) {
      return const Center(child: Text('Failed to initialize'));
    }

    return ListenableBuilder(
      listenable: _debatesProvider!,
      builder: (context, _) {
        if (_debatesProvider!.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final debate = _debatesProvider!.currentDebate;
        if (debate == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_debatesProvider!.error ?? 'Failed to load debate'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _debatesProvider!.loadDebate(widget.debateAddress),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Set current argument to root if not set
        if (_currentArgument == null && debate.rootArgument != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _currentArgument = debate.rootArgument);
            }
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                _buildDebateHeader(debate),
                const Divider(height: 1),
                Expanded(
                  child: _currentArgument != null
                      ? _buildArgumentView(debate, _currentArgument!)
                      : const Center(child: Text('No arguments')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebateHeader(Debate debate) {
    final sentimentColor = debate.debateSentiment > BigInt.zero
        ? Colors.green
        : debate.debateSentiment < BigInt.zero
            ? Colors.red
            : Colors.grey;

    return Container(
      color: const Color(0xff2c2c2c),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  debate.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _debatesProvider!.refreshCurrentDebate(),
                tooltip: 'Refresh debate',
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: debate.isOpen
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  debate.isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    color: debate.isOpen ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatChip(
                icon: Icons.trending_up,
                label: 'Sentiment',
                value: debate.sentimentFormatted >= 0
                    ? '+${debate.sentimentFormatted.toStringAsFixed(2)}'
                    : debate.sentimentFormatted.toStringAsFixed(2),
                color: sentimentColor,
              ),
              _buildStatChip(
                icon: Icons.comment_outlined,
                label: 'Arguments',
                value: '${debate.argumentCount}',
                color: Colors.grey,
              ),
              _buildStatChip(
                icon: Icons.how_to_vote,
                label: 'Total Staked',
                value: formatTotalSupply(debate.totalStakedWeight.toString(), 18),
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArgumentView(Debate debate, DebateArgument argument) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb / Navigation
          if (!argument.isRoot)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: _navigateToParent,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: Color(0xffa1d0d0)),
                    const SizedBox(width: 8),
                    Text(
                      'Back to parent argument',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),

          // Current Argument Card
          ArgumentDetailCard(
            argument: argument,
            org: _org!,
            isRoot: argument.isRoot,
          ),
          const SizedBox(height: 24),

          // Pro/Con Sections - responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              if (isMobile) {
                return Column(
                  children: [
                    _buildArgumentSection(
                      title: 'Supporting Arguments',
                      arguments: argument.proChildren,
                      color: Colors.green,
                      argType: ArgumentType.pro,
                      debate: debate,
                    ),
                    const SizedBox(height: 16),
                    _buildArgumentSection(
                      title: 'Opposing Arguments',
                      arguments: argument.conChildren,
                      color: Colors.red,
                      argType: ArgumentType.con,
                      debate: debate,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildArgumentSection(
                      title: 'Supporting Arguments',
                      arguments: argument.proChildren,
                      color: Colors.green,
                      argType: ArgumentType.pro,
                      debate: debate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildArgumentSection(
                      title: 'Opposing Arguments',
                      arguments: argument.conChildren,
                      color: Colors.red,
                      argType: ArgumentType.con,
                      debate: debate,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArgumentSection({
    required String title,
    required List<DebateArgument> arguments,
    required Color color,
    required ArgumentType argType,
    required Debate debate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  argType == ArgumentType.pro ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  '$title (${arguments.length})',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const Spacer(),
                if (debate.isOpen)
                  IconButton(
                    icon: Icon(Icons.add, color: color),
                    onPressed: () => _showAddArgumentDialog(argType),
                    tooltip: 'Add ${argType == ArgumentType.pro ? 'supporting' : 'opposing'} argument',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          // Arguments List
          if (arguments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No ${argType == ArgumentType.pro ? 'supporting' : 'opposing'} arguments yet',
                  style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: arguments.length,
              itemBuilder: (context, index) {
                final arg = arguments[index];
                return ArgumentListItem(
                  argument: arg,
                  org: _org!,
                  onTap: () => _navigateToArgument(arg),
                );
              },
            ),
        ],
      ),
    );
  }
}
