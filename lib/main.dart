import 'package:db_app/db_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App with DB',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _entries = [];


  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _entries = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Succesfully deleted a Todo!'),
    ));
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
      _entries.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }
                      if (id != null) {
                        await _updateItem(id);
                      }
                      _titleController.text = '';
                      _descriptionController.text = '';

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App with DB"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
      body: ListView.builder(
          itemCount: _entries.length,
          itemBuilder: (context, index) => Dismissible(
                key: ValueKey(_entries[index]['id'].toString()),
                background: Container(
                  color: Colors.redAccent,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.delete, size: 40),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: const Text("Please Confirm"),
                            content:
                                const Text("Are you sure you want to delete?"),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                  child: const Text("Cancel")),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                  },
                                  child: const Text("Delete")),
                            ],
                          ));
                },
                onDismissed: (DismissDirection direction) {
                  if (direction == DismissDirection.endToStart) {
                    _deleteItem(_entries[index]['id']);
                  }
                },
                child: Card(
                  color: Colors.blueGrey,
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(_entries[index]['title']),
                    subtitle: Text(_entries[index]['description']),
                    leading: SizedBox(
                      width: 48,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_entries[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
    );
  }
}
