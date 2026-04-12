import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'product_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<dynamic> _products = [];
  List<dynamic> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final pRes = await http.get(Uri.parse('http://72.60.241.246:5001/api/Products'));
      final fRes = await http.get(Uri.parse('http://72.60.241.246:5001/api/Favorites/1'));
      
      setState(() {
        if (pRes.statusCode == 200) _products = json.decode(pRes.body);
        if (fRes.statusCode == 200) _favorites = json.decode(fRes.body);
        _isLoading = false;
      });
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
          const Text("Hola, Admin 👋", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("¿Qué deseas consultar hoy?", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          const SizedBox(height: 24),
          _buildFavoritesSection(),
          const SizedBox(height: 32),
          const Text("Todos los Productos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._products.map((p) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.eco, color: Colors.green)),
            title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(p['categoryName']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p['id'], marketId: 1, productName: p['name']))),
          ))
        ],
      )
    );
  }

  Widget _buildFavoritesSection() {
    if (_favorites.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tus Favoritos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _favorites.length,
            itemBuilder: (context, i) {
              final f = _favorites[i];
              return FavoriteCard(f: f);
            },
          ),
        )
      ],
    );
  }
}

class FavoriteCard extends StatefulWidget {
  final dynamic f;
  const FavoriteCard({super.key, required this.f});
  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  List<dynamic> _prices = [];
  
  @override
  void initState() {
    super.initState();
    _fetchTrend();
  }

  Future<void> _fetchTrend() async {
    try {
      final res = await http.get(Uri.parse('http://72.60.241.246:5001/api/Prices/product/${widget.f['productID']}?marketId=${widget.f['marketID']}'));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        final ascendingData = List<dynamic>.from(data.reversed);
        final last7 = ascendingData.length > 7 ? ascendingData.sublist(ascendingData.length - 7) : ascendingData;
        if (mounted) setState(() => _prices = last7);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: widget.f['productID'], marketId: widget.f['marketID'], productName: widget.f['productName']))),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Stack(
          children: [
            if (_prices.isNotEmpty)
              Positioned(
                left: -16, right: -16, top: 0, bottom: -16,
                child: Opacity(
                  opacity: 0.35,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _prices.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['averagePricePerKg'] as num).toDouble())).toList(),
                          isCurved: true,
                          color: Colors.white,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 28),
                const SizedBox(height: 12),
                Text(widget.f['productName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
