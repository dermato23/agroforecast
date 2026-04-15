import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _priceAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones y Alertas', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Configura cómo y cuándo deseas que AgroForecast te contacte.',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 30),
          SwitchListTile(
            title: const Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Recibe alertas en tu dispositivo sobre tus mercados frecuentados'),
            value: _pushEnabled,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() { _pushEnabled = value; });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Alertas de Precios', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Avisa cuando haya movimientos inusuales de precios (+/- 10%)'),
            value: _priceAlerts,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() { _priceAlerts = value; });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Boletín Semanal por Correo', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Resumen semanal de tendencias y ahorros a tu cuenta'),
            value: _emailEnabled,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() { _emailEnabled = value; });
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferencias guardadas con éxito')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Guardar Cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }
}
