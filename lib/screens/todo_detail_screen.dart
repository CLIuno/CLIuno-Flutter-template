import 'package:flutter/material.dart';

import '../apis/http.dart';
import '../apis/todo_api.dart';

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = true;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await todoApi.getTodoById(widget.id);
      final todo = ((res.data['data'] as Map)['todo'] as Map)
          .cast<String, dynamic>();
      if (!mounted) return;
      setState(() {
        _titleCtrl.text = (todo['title'] ?? '') as String;
        _descCtrl.text = (todo['description'] ?? '') as String;
        _done = todo['is_completed'] == true || todo['is_completed'] == 1;
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

  Future<void> _save() async {
    try {
      await todoApi.updateTodo(widget.id, {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
      });
      if (!mounted) return;
      _snack('Todo saved');
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _toggle() async {
    try {
      await todoApi.toggleTodo(widget.id);
      if (!mounted) return;
      setState(() => _done = !_done);
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _delete() async {
    try {
      await todoApi.deleteTodo(widget.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                SwitchListTile(
                  title: const Text('Completed'),
                  value: _done,
                  onChanged: (_) => _toggle(),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
    );
  }
}
