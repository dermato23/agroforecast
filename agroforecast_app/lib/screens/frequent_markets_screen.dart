import 'package:flutter/material.dart';

class FrequentMarketsScreen extends StatelessWidget {
  const FrequentMarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mis Mercados', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actualmente el pronóstico y el motor de decisiones inteligente de AgroForecast está calibrado con la Central Mayorista de Corabastos como primera fase.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            _buildMarketCard('Corabastos, Bogotá', 'Mercado Activo Principal', true),
            const SizedBox(height: 16),
            _buildMarketCard('Paloquemao, Bogotá', 'Próximamente disponible', false),
            const SizedBox(height: 16),
            _buildMarketCard('Plaza Samper Mendoza', 'Próximamente disponible', false),
            
            const Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text('Sugerir nuevo mercado', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarketCard(String name, String status, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green.shade200 : Colors.transparent),
      ),
      child: ListTile(
        leading: Icon(
          Icons.storefront, 
          color: isActive ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey.shade600)),
        subtitle: Text(status, style: TextStyle(color: isActive ? Colors.green.shade700 : Colors.grey)),
        trailing: isActive ? const Icon(Icons.check_circle, color: Colors.green) : null,
      ),
    );
  }
}
