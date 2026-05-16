import 'package:flutter/material.dart';

import '../storage/prefs_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.prefsService});

  final PrefsService prefsService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final ok = await widget.prefsService.login(
        username: _userController.text,
        password: _passController.text,
      );
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña inválidos')),
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomePage(prefsService: widget.prefsService),
        ),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPage(prefsService: widget.prefsService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Iniciar sesión',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'El usuario es obligatorio';
                            if (v.length < 3) return 'Mínimo 3 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _saving ? null : _login(),
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _login,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _saving ? null : _goRegister,
                          child: const Text('Crear cuenta'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
