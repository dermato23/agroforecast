import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SavingsTab extends StatefulWidget {
  const SavingsTab({super.key});
  @override
  State<SavingsTab> createState() => _SavingsTabState();
}

class _SavingsTabState extends State<SavingsTab> {
  List<dynamic> _logs = [];
  double _totalSaved = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavings();
  }

  Future<void> _fetchSavings() async {
    try {
      final res = await http.get(Uri.parse('http://72.60.241.246:5001/api/Profile/1'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _logs = data['logs'] ?? [];
          _totalSaved = (data['totalSaved'] as num).toDouble();
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32))
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                const SizedBox(height: 16),
                const Text("Total Ahorrado", style: TextStyle(color: Colors.white70, fontSize: 18)),
                Text("\$${_totalSaved.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _logs.length,
              itemBuilder: (context, i) {
                final log = _logs[i];
                final date = DateFormat('dd MMM yyyy').format(DateTime.parse(log['date']));
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.attach_money, color: Colors.green)),
                    title: Text("Ahorro de \$${log['savedAmount'].toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("$date • ${log['kilosBought']} Kg comprobados"),
                  ),
                );
              },
            ),
          )
        ],
      )
    );
  }
}
