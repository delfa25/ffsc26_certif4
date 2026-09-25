import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: Text('Aucun utilisateur connecté'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade100,
            backgroundImage: user.image.isNotEmpty ? NetworkImage(user.image) : null,
            child: user.image.isEmpty
                ? Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName.isNotEmpty ? user.fullName : user.username,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            '@${user.username}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // User details card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFF6750A4)),
                    title: const Text('Email'),
                    subtitle: Text(user.email.isNotEmpty ? user.email : 'Non disponible'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF6750A4)),
                    title: const Text('Genre'),
                    subtitle: Text(user.gender.isNotEmpty ? user.gender : 'Non spécifié'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.verified_user, color: Color(0xFF6750A4)),
                    title: const Text('ID Utilisateur'),
                    subtitle: Text('#${user.id}'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.token, color: Color(0xFF6750A4)),
                    title: const Text('Jeton JWT'),
                    subtitle: Text(
                      user.accessToken != null
                          ? '${user.accessToken!.substring(0, 15)}...'
                          : 'Jeton actif',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.read<AuthProvider>().logout();
                        },
                        child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
