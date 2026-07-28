import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../apis/http.dart';
import '../apis/post_api.dart';
import '../apis/upload_api.dart';
import '../apis/user_api.dart';
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
  bool _uploading = false;

  /// Pick an image, push it to POST /uploads/image, then attach the returned
  /// URL to the signed-in user with PATCH /users/current.
  Future<void> _changeAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final res = await uploadApi.uploadImage(picked.path);
      final url = (res.data['data'] as Map)['url'] as String;
      await userApi.updateCurrentUser({'avatar_url': url});
      await AuthStore.instance.fetchCurrentUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiMessage(e))));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

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
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage:
                        (user?['avatar_url'] is String &&
                            (user?['avatar_url'] as String).isNotEmpty)
                        ? NetworkImage(user?['avatar_url'] as String)
                        : null,
                    child:
                        (user?['avatar_url'] is String &&
                            (user?['avatar_url'] as String).isNotEmpty)
                        ? null
                        : const Icon(Icons.person, size: 36),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _uploading ? null : _changeAvatar,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text(_uploading ? 'Uploading…' : 'Change photo'),
                  ),
                ),
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
