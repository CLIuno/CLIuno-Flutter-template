import 'package:flutter/material.dart';

import '../stores/auth_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await AuthStore.instance.login(
      _loginCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/todos');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthStore.instance.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _loginCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username or email',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Don't have an account? Register"),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
