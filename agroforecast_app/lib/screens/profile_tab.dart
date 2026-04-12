import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await http.get(Uri.parse('http://72.60.241.246:5001/api/Profile/1'));
      if (res.statusCode == 200) {
        setState(() {
          _user = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                ),
                const SizedBox(height: 16),
                Text(_user?['name'] ?? 'Usuario', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(_user?['email'] ?? 'correo@ejemplo.com', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSettingsTile(Icons.notifications_outlined, 'Notificaciones y Alertas'),
          _buildSettingsTile(Icons.security, 'Privacidad y Seguridad'),
          _buildSettingsTile(Icons.favorite_border, 'Mis Mercados Frecuentes'),
          _buildSettingsTile(Icons.help_outline, 'Ayuda y Soporte Técnico'),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {},
          )
        ],
      )
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
        Divider(color: Colors.grey.shade100, height: 1),
      ],
    );
  }
}
