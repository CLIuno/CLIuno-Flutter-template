import 'package:flutter/material.dart';

import '../apis/http.dart';
import '../apis/user_api.dart';
import '../widgets/app_drawer.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await userApi.getUsers();
      final list = (res.data['data'] as Map)['users'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _users = list.map((u) => (u as Map).cast<String, dynamic>()).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  final user = _users[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('@${user['username']}'),
                    subtitle: Text((user['email'] ?? '') as String),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailScreen(id: '${user['id']}'),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
