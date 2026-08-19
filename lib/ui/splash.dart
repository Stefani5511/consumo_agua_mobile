import 'package:flutter/material.dart';

import 'home.dart';
import 'style/theme.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    final temaEscuro = AppTheme.modo.value == ThemeMode.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Image.asset('./assets/icone.png', width: 200),
            SwitchListTile(
              title: const Text("Tema escuro"),
              value: temaEscuro,
              onChanged: (value) {
                setState(() {
                  AppTheme.modo.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                });
              },
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              ),
              child: const Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}