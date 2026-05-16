import 'package:flutter/material.dart';

import '../storage/prefs_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key, required this.prefsService});

  final PrefsService prefsService;

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final loggedIn = await widget.prefsService.isLoggedIn();
    final username = await widget.prefsService.getUsername();
    if (!mounted) return;

    final page = loggedIn && username != null
        ? HomePage(prefsService: widget.prefsService)
        : LoginPage(prefsService: widget.prefsService);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
