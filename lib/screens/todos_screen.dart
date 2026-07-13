import 'package:flutter/material.dart';

import '../apis/http.dart';
import '../apis/todo_api.dart';
import '../widgets/app_drawer.dart';
import 'todo_detail_screen.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  List<Map<String, dynamic>> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await todoApi.getTodos();
      final list = (res.data['data'] as Map)['todos'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _todos = list.map((t) => (t as Map).cast<String, dynamic>()).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(apiMessage(e));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // SQLite-backed templates serialize booleans as 0/1.
  bool _done(Map<String, dynamic> todo) =>
      todo['is_completed'] == true || todo['is_completed'] == 1;

  Future<void> _addTodo() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || titleCtrl.text.trim().isEmpty) return;
    try {
      await todoApi.createTodo({
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
      });
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _toggle(Map<String, dynamic> todo) async {
    try {
      await todoApi.toggleTodo('${todo['id']}');
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _delete(Map<String, dynamic> todo) async {
    try {
      await todoApi.deleteTodo('${todo['id']}');
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _todos.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No todos yet — add one!')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, i) {
                        final todo = _todos[i];
                        return ListTile(
                          leading: Checkbox(
                            value: _done(todo),
                            onChanged: (_) => _toggle(todo),
                          ),
                          title: Text(
                            (todo['title'] ?? '') as String,
                            style: _done(todo)
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : null,
                          ),
                          subtitle: (todo['description'] is String &&
                                  (todo['description'] as String).isNotEmpty)
                              ? Text(todo['description'] as String)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(todo),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TodoDetailScreen(id: '${todo['id']}'),
                              ),
                            );
                            await _load();
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
