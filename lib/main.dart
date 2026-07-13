import 'package:flutter/material.dart';

import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/todos_screen.dart';
import 'screens/users_screen.dart';
import 'stores/auth_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStore.instance.hydrate();
  runApp(const CliunoApp());
}

class CliunoApp extends StatelessWidget {
  const CliunoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CLIuno Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: AuthStore.instance.isAuthenticated ? '/todos' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/todos': (_) => const TodosScreen(),
        '/posts': (_) => const PostsScreen(),
        '/users': (_) => const UsersScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
