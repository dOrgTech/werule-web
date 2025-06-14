import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../entities/token.dart';
import '../main.dart';
import '../widgets/gameOfLife.dart';
import '../widgets/menu.dart';
import '../entities/org.dart';
import '../widgets/daocard.dart';
import 'creator.dart';

class Explorer extends StatefulWidget {
  Explorer({super.key});
  Widget? game;
  String query = "";
  bool loaded = false;
  List<Widget> daos = [];
  TextEditingController controlla = TextEditingController();

  Future<String> getDaos() async {
    var daosSnapshot = await daosCollection.get();
    orgs = [];
    for (var doc in daosSnapshot.docs) {
      try {
        Org org = Org(
            name: doc.data()['name'],
            description: doc.data()['description'],
            govTokenAddress: doc.data()['govTokenAddress']);
        org.address = doc.data()['address'];
        org.symbol = doc.data()['symbol'];
        org.creationDate = (doc.data()['creationDate'] as Timestamp).toDate();
        org.govToken = Token(
            type: "erc20",
            symbol: org.symbol!,
            decimals: org.decimals,
            name: org.name);
        org.govTokenAddress = doc.data()['token'];
        org.proposalThreshold = doc.data()['proposalThreshold'];
        org.votingDelay = doc.data()['votingDelay'];
        org.treasuryAddress = doc.data()['treasuryAddress'];
        org.registryAddress = doc.data()['registryAddress'];
        org.votingDuration = doc.data()['votingDuration'];
        org.executionDelay = doc.data()['executionDelay'];
        org.quorum = doc.data()['quorum'];
        org.decimals = doc.data()['decimals'];
        org.holders = doc.data()['holders'];
        org.treasuryMap = Map<String, String>.from(doc.data()['treasury']);
        org.registry = Map<String, String>.from(doc.data()['registry']);
        org.totalSupply = doc.data()['totalSupply'];

        // Populate the 'wrapped' field
        var wrappedValue = doc.data()['wrapped'];
        if (wrappedValue is String) {
          org.wrapped = wrappedValue;
          print("[Explorer.getDaos] Org '${org.name}' - FOUND A WRAPPED TOKEN string: ${org.wrapped}");
        } else {
          org.wrapped = null;
          if (wrappedValue != null) {
            print("[Explorer.getDaos] Org '${org.name}' - Firestore field 'wrapped' was not null but was not a String. Type: ${wrappedValue.runtimeType}, Value: $wrappedValue");
          }
        }

        if (org.name.contains("dOrg")) {
          print("debates only ${org.name}");
          org.debatesOnly = true;
        } else {
          print("Full DAO  ${org.name}");
          org.debatesOnly = false;
        }
        orgs.add(org);
      } catch (e) {
        print("could not go $e");
      }
    }
    return "done";
  }

  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  final int _itemsPerPage = 21;
  int _currentPage = 1;
  int _totalPages = 1;
  List<Org> _filteredOrgs = [];

  @override
  void initState() {
    widget.game = Container();
    super.initState();
  }

  @override
  void dispose() {
    widget.game = const SizedBox();
    super.dispose();
  }

  void _applyFilterAndPagination() {
    _filteredOrgs =
        orgs.where((o) => o.name.toLowerCase().contains(widget.query)).toList();

    _totalPages = (_filteredOrgs.length / _itemsPerPage).ceil();
    if (_totalPages == 0) {
      _totalPages = 1;
    }
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _filteredOrgs.length) {
      endIndex = _filteredOrgs.length;
    }

    widget.daos = _filteredOrgs
        .sublist(startIndex, endIndex)
        .map((org) => DAOCard(org: org))
        .toList();
  }

  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
      _applyFilterAndPagination();
    });
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _currentPage > 1 ? () => _changePage(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed:
              _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
        ),
        Text('Page $_currentPage of $_totalPages'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: _currentPage < _totalPages
              ? () => _changePage(_currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _currentPage < _totalPages
              ? () => _changePage(_totalPages)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          TextButton(onPressed: () {}, child: const Icon(Icons.help_center)),
      appBar: const TopMenu(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            const Opacity(opacity: 0.03, child: GameOfLife()),
            Container(
              alignment: Alignment.topCenter,
              child: widget.loaded == true
                  ? wide()
                  : FutureBuilder<String>(
                      future: widget.getDaos(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        widget.loaded = true;
                        _applyFilterAndPagination();
                        return wide();
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget wide() {
    return ListView(
      shrinkWrap: true,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 80,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 1200
                          ? 550
                          : MediaQuery.of(context).size.width * 0.5,
                      child: TextField(
                        controller: widget.controlla,
                        onChanged: (value) {
                          final cursorPosition = widget.controlla.selection;
                          setState(() {
                            widget.query = value.toLowerCase();
                            _currentPage = 1;
                            _applyFilterAndPagination();
                          });
                          widget.controlla.value =
                              widget.controlla.value.copyWith(
                            text: value,
                            selection: cursorPosition,
                          );
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(width: 0.1),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search by DAO Name or Token Symbol',
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        Text("${_filteredOrgs.length} DAOs"),
                        const SizedBox(width: 30),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(width: 0, color: Colors.black)),
                          height: 40,
                          child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Scaffold(body: DaoSetupWizard())));
                              },
                              style: TextButton.styleFrom(
                                  disabledBackgroundColor: Colors.grey,
                                  elevation: 5,
                                  backgroundColor: Theme.of(context)
                                      .indicatorColor
                                      .withOpacity(0.92)),
                              child: const Text(
                                "Create DAO",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontFamily: 'CascadiaCode',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold),
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.topCenter,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: widget.daos,
              ),
            ),
            const SizedBox(height: 20),
            _buildPaginationControls(),
          ],
        ),
        const SizedBox(height: 83),
      ],
    );
  }
}
