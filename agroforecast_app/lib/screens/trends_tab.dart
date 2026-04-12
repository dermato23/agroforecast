import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_detail_screen.dart';

class TrendsTab extends StatefulWidget {
  const TrendsTab({super.key});
  @override
  State<TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends State<TrendsTab> {
  List<dynamic> _trendCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrends();
  }

  Future<void> _fetchTrends() async {
    try {
      final res = await http.get(Uri.parse('http://72.60.241.246:5001/api/Analytics/trends'));
      if (res.statusCode == 200) {
        setState(() {
          _trendCategories = json.decode(res.body);
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
          const Text("Tendencias", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Top 3 mayores bajadas porcentuales por categoría en los últimos 7 días.", style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ..._trendCategories.map((cat) => _buildCategorySection(cat))
        ],
      )
    );
  }

  Widget _buildCategorySection(dynamic cat) {
    List<dynamic> items = cat['top3'];
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cat['category'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 12),
        ...items.map((item) {
          final drop = (item['dropPercentage'] as num).toDouble();
          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Hace 7d: \$${item['pastPrice'].toStringAsFixed(0)} \nHoy: \$${item['currentPrice'].toStringAsFixed(0)}\nEn ${item['market']}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_downward, color: Colors.green),
                  Text("${drop.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))
                ],
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: item['productId'], marketId: item['marketId'], productName: item['productName']))),
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}
