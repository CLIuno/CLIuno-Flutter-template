import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../apis/http.dart';
import '../apis/post_api.dart';
import '../apis/upload_api.dart';
import '../widgets/app_drawer.dart';
import 'post_detail_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await postApi.getPosts();
      final list = (res.data['data'] as Map)['posts'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _posts = list.map((p) => (p as Map).cast<String, dynamic>()).toList();
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

  Future<void> _addPost() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String? imageUrl;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked == null) return;
                      try {
                        final res = await uploadApi.uploadImage(picked.path);
                        setDialogState(() {
                          imageUrl = (res.data['data'] as Map)['url'] as String;
                        });
                      } catch (e) {
                        if (mounted) _snack(apiMessage(e));
                      }
                    },
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(
                      imageUrl == null ? 'Add image' : 'Replace image',
                    ),
                  ),
                  if (imageUrl != null)
                    TextButton(
                      onPressed: () => setDialogState(() => imageUrl = null),
                      child: const Text('Remove'),
                    ),
                ],
              ),
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
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
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || titleCtrl.text.trim().isEmpty) return;
    try {
      await postApi.createPost({
        'title': titleCtrl.text.trim(),
        'content': contentCtrl.text.trim(),
        'image_url': ?imageUrl,
      });
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _posts.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No posts yet — publish one!'),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, i) {
                        final post = _posts[i];
                        final author =
                            ((post['user'] as Map?)?['username'] ?? '')
                                as String;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text((post['title'] ?? '') as String),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (post['content'] ?? '') as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (post['image_url'] is String &&
                                    (post['image_url'] as String).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        post['image_url'] as String,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: author.isEmpty
                                ? null
                                : Text(
                                    '@$author',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
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
                        );
                      },
                    ),
            ),
    );
  }
}
