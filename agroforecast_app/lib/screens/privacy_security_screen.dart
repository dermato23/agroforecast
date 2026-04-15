import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacidad y Seguridad', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.security, size: 60, color: Colors.green),
          const SizedBox(height: 20),
          const Text('Política de Privacidad', 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'En AgroForecast nos tomamos muy en serio la seguridad de tu información. '
            'Los datos recopilados sobre tus decisiones de compra o mercados favoritos se '
            'utilizan exclusivamente de manera anónima para construir nuestro modelo '
            'estadístico predictivo.\n\n'
            'No compartimos tu información personal con terceros sin tu consentimiento '
            'explícito.\n\n'
            'Ultima actualización: 15 de Abril, 2026.',
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Términos de Servicio', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo documento...')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Eliminar Mi Cuenta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            subtitle: const Text('Esta acción es irreversible', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar tu cuenta?'),
        content: const Text(
          'Toda tu información, tendencias guardadas y perfil serán eliminados para siempre de nuestros servidores.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Solicitud de eliminación enviada.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Eliminar Todo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
