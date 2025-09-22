// lib/src/features/dao_creator/screens/screen6_registry.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/widgets/creator_widgets.dart';

class Screen6Registry extends StatefulWidget {
  final DaoCreatorProvider provider;

  const Screen6Registry({
    super.key,
    required this.provider,
  });

  @override
  _Screen6RegistryState createState() => _Screen6RegistryState();
}

class _Screen6RegistryState extends State<Screen6Registry> {
  List<RegistryEntry> _registryEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.provider.registry.isNotEmpty) {
      _registryEntries = widget.provider.registry.entries
          .map((entry) => RegistryEntry(
                keyController: TextEditingController(text: entry.key),
                valueController: TextEditingController(text: entry.value),
              ))
          .toList();
    } else {
      _addRegistryEntry(); // Add one entry by default if empty
    }
  }

  void _addRegistryEntry() {
    setState(() {
      _registryEntries.add(RegistryEntry(
        keyController: TextEditingController(),
        valueController: TextEditingController(),
      ));
    });
  }

  void _removeRegistryEntry(int index) {
    setState(() {
      _registryEntries[index].keyController.dispose();
      _registryEntries[index].valueController.dispose();
      _registryEntries.removeAt(index);
    });
  }

  void _saveAndNext() {
    final newRegistry = Map.fromEntries(_registryEntries
        .where((entry) =>
            entry.keyController.text.isNotEmpty ||
            entry.valueController.text.isNotEmpty)
        .map(
          (entry) => MapEntry(
            entry.keyController.text,
            entry.valueController.text,
          ),
        ));
    widget.provider.updateRegistry(newRegistry);
    widget.provider.nextStep();
  }

  @override
  void dispose() {
    for (var entry in _registryEntries) {
      entry.keyController.dispose();
      entry.valueController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // THE FIX: Wrapped the main column in a Center widget for consistent alignment.
        child: Center(
          child: Column(
            children: [
              Text('Registry Entries',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 26),
              const Text(
                  'Add key-value pairs to initialize the DAO\'s registry.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 194, 194, 194))),
              const SizedBox(height: 53),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _registryEntries.length,
                itemBuilder: (context, index) {
                  return RegistryEntryWidget(
                    entry: _registryEntries[index],
                    onRemove: () => _removeRegistryEntry(index),
                  );
                },
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 160,
                  child: TextButton(
                    onPressed: _addRegistryEntry,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.add), Text(' Add Entry')],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 126),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: widget.provider.previousStep,
                        child: const Text('< Back')),
                    ElevatedButton(
                        onPressed: _saveAndNext,
                        child: const Text('Save and Continue >')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen6_registry.dart