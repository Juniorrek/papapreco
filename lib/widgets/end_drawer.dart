import 'package:flutter/material.dart';
import 'package:premiumprice/misc/auth/auth_provider.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:provider/provider.dart';

class EndDrawer extends StatelessWidget {
  const EndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthProvider>().usuario!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 80, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usuario.nome, style: const TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(usuario.email, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                )),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Routes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Alterar senha'),
            onTap: () {
              Navigator.pushNamed(context, Routes.alterarSenha);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, Routes.home);
              //Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
