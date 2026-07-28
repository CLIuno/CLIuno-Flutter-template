import 'package:flutter/material.dart';

import '../apis/http.dart';
import '../apis/post_api.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();
  Map<String, dynamic>? _post;
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final postRes = await postApi.getPostById(widget.id);
      final commentsRes = await postApi.getComments(widget.id);
      final comments =
          (commentsRes.data['data'] as Map)['comments'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _post = ((postRes.data['data'] as Map)['post'] as Map)
            .cast<String, dynamic>();
        _comments = comments
            .map((c) => (c as Map).cast<String, dynamic>())
            .toList();
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

  Future<void> _addComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty) return;
    try {
      await postApi.createComment(widget.id, {'content': content});
      _commentCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _deleteComment(Map<String, dynamic> comment) async {
    try {
      await postApi.deleteComment(widget.id, '${comment['id']}');
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _editPost() async {
    final titleCtrl = TextEditingController(
      text: (_post?['title'] ?? '') as String,
    );
    final contentCtrl = TextEditingController(
      text: (_post?['content'] ?? '') as String,
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Content'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await postApi.updatePost(widget.id, {
        'title': titleCtrl.text.trim(),
        'content': contentCtrl.text.trim(),
      });
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  Future<void> _deletePost() async {
    try {
      await postApi.deletePost(widget.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final author = ((_post?['user'] as Map?)?['username'] ?? '') as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editPost,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deletePost,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        (_post?['title'] ?? '') as String,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (author.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '@$author',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text((_post?['content'] ?? '') as String),
                      if (_post?['image_url'] is String &&
                          (_post?['image_url'] as String).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _post?['image_url'] as String,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const Divider(height: 32),
                      Text(
                        'Comments (${_comments.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final comment in _comments)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text((comment['content'] ?? '') as String),
                          subtitle: Text(
                            '@${((comment['user'] as Map?)?['username'] ?? 'unknown')}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _deleteComment(comment),
                          ),
                        ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment…',
                            ),
                            onSubmitted: (_) => _addComment(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
