import 'package:flutter/material.dart';

import '../stores/auth_store.dart';

/// Navigation drawer shared by the authenticated screens.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthStore.instance.user;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text((user?['username'] ?? 'CLIuno') as String),
            accountEmail: Text((user?['email'] ?? '') as String),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          _item(context, Icons.check_circle_outline, 'Todos', '/todos'),
          _item(context, Icons.article_outlined, 'Posts', '/posts'),
          _item(context, Icons.people_outline, 'Users', '/users'),
          _item(context, Icons.account_circle_outlined, 'Profile', '/profile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthStore.instance.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pushReplacementNamed(context, route),
    );
  }
}
