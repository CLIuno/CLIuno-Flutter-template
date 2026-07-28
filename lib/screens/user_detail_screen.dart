import 'package:flutter/material.dart';

import '../apis/follow_api.dart';
import '../apis/http.dart';
import '../apis/user_api.dart';
import '../stores/auth_store.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? _user;
  int _followers = 0;
  int _following = 0;
  bool _isFollowing = false;
  bool _loading = true;

  bool get _isSelf => '${AuthStore.instance.user?['id']}' == widget.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userRes = await userApi.getUserById(widget.id);
      final followersRes = await followApi.getFollowers(widget.id);
      final followingRes = await followApi.getFollowing(widget.id);
      final isFollowingRes = await followApi.isFollowing(widget.id);
      if (!mounted) return;
      setState(() {
        _user = ((userRes.data['data'] as Map)['user'] as Map)
            .cast<String, dynamic>();
        _followers =
            ((followersRes.data['data'] as Map)['followers'] as List? ?? [])
                .length;
        _following =
            ((followingRes.data['data'] as Map)['following'] as List? ?? [])
                .length;
        final flag = (isFollowingRes.data['data'] as Map)['isFollowing'];
        _isFollowing = flag == true || flag == 1;
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

  Future<void> _toggleFollow() async {
    try {
      if (_isFollowing) {
        await followApi.unfollow(widget.id);
      } else {
        await followApi.follow(widget.id);
      }
      await _load();
    } catch (e) {
      if (mounted) _snack(apiMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = [
      _user?['first_name'],
      _user?['last_name'],
    ].whereType<String>().join(' ');
    return Scaffold(
      appBar: AppBar(title: Text('@${_user?['username'] ?? '…'}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage:
                        (_user?['avatar_url'] is String &&
                            (_user?['avatar_url'] as String).isNotEmpty)
                        ? NetworkImage(_user?['avatar_url'] as String)
                        : null,
                    child:
                        (_user?['avatar_url'] is String &&
                            (_user?['avatar_url'] as String).isNotEmpty)
                        ? null
                        : const Icon(Icons.person, size: 36),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    name.isEmpty ? '@${_user?['username']}' : name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Center(child: Text((_user?['email'] ?? '') as String)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat(context, 'Followers', _followers),
                    const SizedBox(width: 24),
                    _stat(context, 'Following', _following),
                  ],
                ),
                const SizedBox(height: 16),
                if (!_isSelf)
                  Center(
                    child: FilledButton.icon(
                      onPressed: _toggleFollow,
                      icon: Icon(
                        _isFollowing ? Icons.person_remove : Icons.person_add,
                      ),
                      label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _stat(BuildContext context, String label, int count) {
    return Column(
      children: [
        Text('$count', style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
