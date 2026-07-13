import 'package:flutter/material.dart';

import '../stores/auth_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _usernameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _passwordCtrl,
      _confirmCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // Request keys match the shared contract (snake_case fields on register).
    final ok = await AuthStore.instance.register({
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'password_confirmation': _confirmCtrl.text,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered! Verify your email, then log in.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthStore.instance.error ?? 'Registration failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Valid email required'
                        : null,
                  ),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                    ),
                  ),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'At least 8 characters'
                        : null,
                  ),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                    validator: (v) =>
                        v != _passwordCtrl.text ? 'Passwords must match' : null,
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
                        : const Text('Create account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
