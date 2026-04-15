import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ayuda y Soporte', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Preguntas Frecuentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFaqItem(
            '¿Cómo funciona el semáforo inteligente?', 
            'AgroForecast analiza la tendencia histórica semanal recopilada por n8n para comparar el precio de hoy contra el promedio y el mínimo del mercado.'
          ),
          _buildFaqItem(
            '¿Qué significa "Decisión de Compra"?', 
            'El algoritmo evalúa si existe oportunidad real de ahorro. Si no hay suficientes datos (menos de 7 días), el sistema lo indicará.'
          ),
          _buildFaqItem(
            '¿Se actualizan los precios diariamente?', 
            'Sí, nuestro motor web scraping consulta los boletines oficiales de forma automatizada y alimenta la base de datos central.'
          ),
          
          const SizedBox(height: 40),
          const Text('Contáctanos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: const Text('Soporte Técnico', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('soporte@agroforecast.com'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo cliente de correo...')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Colors.green),
              title: const Text('Asistencia por WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Escríbenos directamente'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo WhatsApp...')),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        Text(answer, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
      ],
    );
  }
}
