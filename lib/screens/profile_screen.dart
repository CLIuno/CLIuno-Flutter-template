import 'package:flutter/material.dart';

import '../apis/http.dart';
import '../apis/post_api.dart';
import '../stores/auth_store.dart';
import '../widgets/app_drawer.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await AuthStore.instance.fetchCurrentUser();
      final res = await postApi.getCurrentUserPosts();
      final list = (res.data['data'] as Map)['posts'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _posts = list.map((p) => (p as Map).cast<String, dynamic>()).toList();
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
    final user = AuthStore.instance.user;
    final name = [
      user?['first_name'],
      user?['last_name'],
    ].whereType<String>().join(' ');
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    name.isEmpty ? '@${user?['username']}' : name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Center(child: Text((user?['email'] ?? '') as String)),
                if (user?['phone'] is String &&
                    (user?['phone'] as String).isNotEmpty)
                  Center(child: Text(user?['phone'] as String)),
                const Divider(height: 32),
                Text(
                  'My posts (${_posts.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final post in _posts)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text((post['title'] ?? '') as String),
                      subtitle: Text(
                        (post['content'] ?? '') as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PostDetailScreen(id: '${post['id']}'),
                          ),
                        );
                        await _load();
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
