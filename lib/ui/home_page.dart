import 'package:flutter/material.dart';

import '../models/home_item.dart';
import '../storage/prefs_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.prefsService});

  final PrefsService prefsService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _username;
  List<HomeItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final username = await widget.prefsService.getUsername();
    final rawItems = username == null
        ? <Map<String, dynamic>>[]
        : await widget.prefsService.loadItemsForUser(username);
    final items = rawItems.map(HomeItem.fromJson).toList(growable: false);

    if (!mounted) return;
    setState(() {
      _username = username;
      _items = items;
      _loading = false;
    });
  }

  Future<void> _persistItems(List<HomeItem> items) async {
    final username = _username;
    if (username == null) return;
    await widget.prefsService.saveItemsForUser(
      username,
      items.map((e) => e.toJson()).toList(growable: false),
    );
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    final newItem = HomeItem(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      createdAt: DateTime.now(),
    );

    final next = [newItem, ..._items];
    await _persistItems(next);

    if (!mounted) return;
    setState(() {
      _items = next;
      _titleController.clear();
      _descController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dato guardado')),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final item = _items[index];

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: Text('¿Eliminar "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final next = [..._items]..removeAt(index);
    await _persistItems(next);

    if (!mounted) return;
    setState(() => _items = next);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Elemento eliminado')),
    );
  }

  Future<void> _clearAllItems() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar datos'),
        content: const Text('¿Borrar todos los datos guardados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final username = _username;
    if (username == null) return;
    await widget.prefsService.clearItemsForUser(username);
    if (!mounted) return;
    setState(() => _items = const []);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos limpiados')),
    );
  }

  Future<void> _logout() async {
    await widget.prefsService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(prefsService: widget.prefsService),
      ),
      (_) => false,
    );
  }

  Future<void> _showSessionHistory() async {
    final username = _username;
    if (username == null) return;

    final sessions = await widget.prefsService.loadSessions(username: username);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Historial de sesiones'),
          content: SizedBox(
            width: 420,
            child: sessions.isEmpty
                ? const Text('Aún no hay sesiones registradas.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: sessions.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final type = (s['type'] ?? '').toString();
                      final at = (s['at'] ?? '').toString();
                      return ListTile(
                        leading: Icon(
                          type == 'logout' ? Icons.logout : Icons.login,
                        ),
                        title: Text(type == 'logout' ? 'Logout' : 'Login'),
                        subtitle: Text(at),
                      );
                    },
                  ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(_username ?? 'Usuario'),
                accountEmail: const Text(''),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historial de sesiones'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showSessionHistory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Limpiar datos'),
                onTap: () {
                  Navigator.of(context).pop();
                  _clearAllItems();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.of(context).pop();
                  _logout();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de'),
                onTap: () {
                  Navigator.of(context).pop();
                  showAboutDialog(
                    context: context,
                    applicationName: 'flutter_udcapp',
                    applicationVersion: '1.0.0',
                    children: const [
                      Text('Integrantes:'),
                      SizedBox(height: 8),
                      Text(
                        '- Shein Jadid Moreno Sarmiento\n'
                        '- Andrés Fernando Jaramillo Beltran\n'
                        '- Daniel Francisco Valle Ortiz\n'
                        '- José Rafael Campos Guerra\n'
                        '- Rodolfo Carlos Martínez Arellano',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bienvenido${_username == null ? '' : ', $_username'}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Título',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return 'Título obligatorio';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _descController,
                                decoration: const InputDecoration(
                                  labelText: 'Descripción',
                                  border: OutlineInputBorder(),
                                ),
                                minLines: 2,
                                maxLines: 3,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return 'Descripción obligatoria';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _addItem,
                                      icon: const Icon(Icons.save),
                                      label: const Text('Guardar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _items.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay datos. Agrega uno con el formulario.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (_, _) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return ListTile(
                                  title: Text(item.title),
                                  subtitle: Text(item.description),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _confirmDelete(index),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
