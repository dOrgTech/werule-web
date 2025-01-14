import 'package:flutter/material.dart';
import '../models/debate.dart';
import '../models/argument.dart';
import 'debate_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    // Build Debate 1
    // var root1 = Argument(
    //     author: "Vintilad31d",
    //     weight: 320,
    //     content: '**Online education** is the future');
    // var pro1a = Argument(
    //     author: "Vintilad31d",
    //     content: 'Globally accessible',
    //     parent: root1,
    //     weight: 349);
    // root1.proArguments.add(pro1a);
    // var con1a = Argument(
    //     content: 'Lack of social interaction',
    //     author: "Vintilad31d",
    //     weight: 320,
    //     parent: root1);
    // root1.conArguments.add(con1a);

    // var debate1 = Debate(
    //   title: 'Should online education replace traditional schools?',
    //   rootArgument: root1,
    // );

    // // Build Debate 2
    // var root2 = Argument(
    //     content: 'AI might become uncontrollable',
    //     author: "Vintilad31d",
    //     weight: 320);
    // var pro2a = Argument(
    //     author: "Vintilad31d",
    //     weight: 320,
    //     content: 'It could surpass humans quickly',
    //     parent: root2);
    // root2.proArguments.add(pro2a);

    // var debate2 = Debate(
    //   title: 'Is AI an existential risk?',
    //   rootArgument: root2,
    // );

    return [];
  }

  // void _addDebate() {
  //   final title = _titleController.text.trim();
  //   final rootText = _rootArgController.text.trim();
  //   if (title.isEmpty || rootText.isEmpty) return;

  //   var rootArg =
  //       Argument(author: "Vintilad31d", weight: 320, content: rootText);
  //   setState(() {
  //     debates.add(Debate(title: title, rootArgument: rootArg));
  //   });
  //   Navigator.of(context).pop();
  //   _titleController.clear();
  //   _rootArgController.clear();
  // }

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
