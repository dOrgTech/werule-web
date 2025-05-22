import 'package:flutter/material.dart';
import '../models/debate.dart';
import 'debate_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Debate> debates;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _rootArgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debates = _generateSampleDebates();
  }

  List<Debate> _generateSampleDebates() {
    return [];
  }

  void _showAddDebateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Debate'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Debate Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rootArgController,
                decoration: const InputDecoration(
                    labelText: 'Main Argument (Markdown supported)'),
                minLines: 3,
                maxLines: 6, // allow larger input
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          // ElevatedButton(
          //   onPressed: _addDebate,
          //   child: const Text('Add'),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: const Text(
                'Debates',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: debates.length,
                itemBuilder: (ctx, index) {
                  final d = debates[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(d.title),
                      subtitle: Text('Root: ${d.rootArgument.content}'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DebateDetailScreen(debate: d),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDebateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
