// lib/src/features/dao_detail/widgets/dao_members_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/member.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/members_service.dart';
import 'package:werule/src/utils/reusable.dart';

class _MemberAvatar extends StatefulWidget {
  final String address;
  final double size;
  const _MemberAvatar({required this.address, required this.size});

  @override
  State<_MemberAvatar> createState() => _MemberAvatarState();
}

class _MemberAvatarState extends State<_MemberAvatar> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() async {
    final data = await generateAvatarAsync(hashString(widget.address), size: widget.size.toInt(), pixelSize: 4);
    if (mounted) {
      setState(() {
        _imageData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _imageData != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: Image.memory(_imageData!),
            )
          : CircleAvatar(
              radius: widget.size / 2,
              backgroundColor: Colors.white24,
            ),
    );
  }
}


class DaoMembersWidget extends StatefulWidget {
  final Org dao;
  const DaoMembersWidget({super.key, required this.dao});

  @override
  State<DaoMembersWidget> createState() => _DaoMembersWidgetState();
}

class _DaoMembersWidgetState extends State<DaoMembersWidget> {
  bool _isLoading = true;
  String? _error;
  List<Member> _allMembers = [];
  List<Member> _displayedMembers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchMembers();
      }
    });
  }

  Future<void> _fetchMembers() async {
    final membersService = context.read<MembersService>();
    final network = context.read<NetworkProvider>().selectedNetwork;

    if (network == null) {
      setState(() { _error = "Network not available."; _isLoading = false; });
      return;
    }

    try {
      final membersData = await membersService.getMembers(widget.dao.govTokenAddress, network.blockExplorerUrl);
      final List<dynamic> items = membersData['items'] ?? [];
      final members = items.map((data) => Member.fromBlockscout(data)).toList();
      
      setState(() { _allMembers = members; _displayedMembers = members; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _filterMembers(String query) {
    final filtered = _allMembers.where((member) => member.address.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() { _searchQuery = query; _displayedMembers = filtered; });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildControls(),
            const SizedBox(height: 15),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 58.0), child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_displayedMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 58.0),
          child: Text(
            _searchQuery.isEmpty ? "No members found for this DAO." : "No members found matching '$_searchQuery'.",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMembersList(_displayedMembers);
        } else {
          return _buildMembersTable(_displayedMembers);
        }
      },
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: TextField(
            onChanged: _filterMembers,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              prefixIcon: Icon(Icons.search),
              hintText: 'Find member by address...',
            ),
          ),
        ),
        const Spacer(flex: 1),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text("${_allMembers.length} Members", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
  
  // --- Mobile View ---
  Widget _buildMembersList(List<Member> members) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          color: const Color(0xff3a3a3a),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            shortenString(member.address),
                            style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            splashRadius: 22,
                            onPressed: () => _copyAddress(member.address),
                            icon: const Icon(Icons.copy, color: Colors.white70),
                          ),
                        ],
                      ),
                      Text(
                        "Balance: ${displayTokenValue(member.balance, widget.dao.decimals)}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Desktop View ---
  Widget _buildMembersTable(List<Member> members) {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1),
          },
          children: const [
            TableRow(
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("ADDRESS")),
                Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.all(8.0), child: Text("BALANCE"))),
              ],
            ),
          ],
        ),
        const Divider(),
        Table(
           columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: members.map((member) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Row(
                  children: [
                    _MemberAvatar(address: member.address, size: 36), // THE FIX IS HERE
                    const SizedBox(width: 12),
                    Text(member.address, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                    const SizedBox(width: 12),
                    IconButton(
                      iconSize: 16,
                      splashRadius: 20,
                      onPressed: () => _copyAddress(member.address),
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    displayTokenValue(member.balance, widget.dao.decimals),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]
          )).toList(),
        ),
      ],
    );
  }

  // --- Helper Methods ---
  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Center(child: Text('Copied address to clipboard')), duration: Duration(seconds: 1)),
    );
  }
  
  Widget _buildAvatar() {
    // THE FIX: The size is changed from 35 to 36 to prevent the crash in reusable.dart
    return const _MemberAvatar(address: "placeholder", size: 36);
  }
  
  String displayTokenValue(String value, int decimals) {
    final BigInt intValue = BigInt.tryParse(value) ?? BigInt.zero;
    if (intValue == BigInt.zero) return '0.00';
    final double doubleValue = intValue / BigInt.from(pow(10, decimals));
    if (doubleValue > 0 && doubleValue < 0.01) {
      return '< 0.01';
    }
    return doubleValue.toStringAsFixed(2);
  }
}
// lib/src/features/dao_detail/widgets/dao_members_widget.dart