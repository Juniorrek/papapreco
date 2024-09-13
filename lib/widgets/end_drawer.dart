import 'package:flutter/material.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:provider/provider.dart';

class EndDrawer extends StatelessWidget {
  const EndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final usuario = context.watch<AuthProvider>().usuario;

    return Drawer(
      child: Column(
        children: [
          if (isLoggedIn && usuario != null)
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nome,
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          usuario.email,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isLoggedIn && usuario != null) ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.home);
              },
            ),
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Alterar senha'),
              onTap: () {
                Navigator.pushNamed(context, Routes.alterarSenha);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Alertas de preço'),
              onTap: () {
                Navigator.pushNamed(context, Routes.alertasUsuario);
              },
            ),
          ] else ...[
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.login);
              },
            ),
            const Spacer(),
          ],
          if (isLoggedIn) ...[
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthProvider>().logout();
                //Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.login);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sucesso!'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
