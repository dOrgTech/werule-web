import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../entities/token.dart';
// import '../main.dart'; // No longer needed for global orgs
import '../entities/human.dart'; // Import Human
import '../widgets/gameOfLife.dart';
import '../widgets/menu.dart';
import '../entities/org.dart';
import '../widgets/daocard.dart';
import 'creator.dart';

class Explorer extends StatefulWidget {
  Explorer({super.key}); 
  Widget? game;
  String query = "";
  // bool loaded = false; // This can be removed as loading is handled by main.dart's FutureBuilder
  List<Widget> daos = []; // This will be populated from the global orgs list
  TextEditingController controlla = TextEditingController();

  // REMOVE getDaos() method entirely, as Explorer will use the global 'orgs' list
  // populated by _persistInternal in main.dart

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
    // Initial filter and pagination should happen after the global orgs are available.
    // We can call this directly in build or once after initState.
    // Since Explorer is built after initialPersistDone, orgs should be ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Ensure widget is still in the tree
        setState(() {
          _applyFilterAndPagination();
        });
      }
    });
  }

  @override
  void dispose() {
    widget.game = const SizedBox();
    super.dispose();
  }

  void _applyFilterAndPagination() {
    // Access orgs from Human instance via Provider
    // Ensure context is available here. If _applyFilterAndPagination is called from initState,
    // it might be too early for Provider.of. It's called from addPostFrameCallback in initState, which is fine.
    // And also from onChanged of TextField, where context is available.
    final human = Provider.of<Human>(context, listen: false);
    _filteredOrgs =
        human.orgs.where((o) => o.name.toLowerCase().contains(widget.query)).toList();

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
              child: wide() // Directly build 'wide' as data is already loaded by main.dart
              // The FutureBuilder here is removed because initialPersistDone in main.dart handles the loading state.
              // By the time Explorer is built, 'orgs' global list should be populated.
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
                          hintText: 'Find DAO by name',
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
