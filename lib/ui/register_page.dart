import 'package:flutter/material.dart';

import '../storage/prefs_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.prefsService});

  final PrefsService prefsService;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _saving = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final ok = await widget.prefsService.registerUser(
        username: _userController.text,
        password: _passController.text,
      );

      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ese usuario ya existe')),
        );
        return;
      }

      final loggedIn = await widget.prefsService.login(
        username: _userController.text,
        password: _passController.text,
      );

      if (!mounted) return;
      if (!loggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar sesión')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
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
                              Icons.person_add_alt_1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Crea tu cuenta',
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
                                  setState(() => _obscure1 = !_obscure1),
                              icon: Icon(
                                _obscure1
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: _obscure1,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) return 'La contraseña es obligatoria';
                            if (v.length < 4) return 'Mínimo 4 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure2 = !_obscure2),
                              icon: Icon(
                                _obscure2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: _obscure2,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _saving ? null : _register(),
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) return 'Confirma la contraseña';
                            if (v != _passController.text) {
                              return 'No coincide con la contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _register,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Crear cuenta'),
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
