import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final int marketId;
  final String productName;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.marketId,
    required this.productName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<dynamic> _priceHistory = [];
  bool _isLoading = true;
  String _error = "";

  String _recommendation = "Analizando...";
  Color _recommendationColor = Colors.grey;
  IconData _recommendationIcon = Icons.hourglass_empty;

  double _sma7 = 0;
  double _currentPrice = 0;

  @override
  void initState() {
    super.initState();
    _fetchPriceHistory();
  }

  Future<void> _fetchPriceHistory() async {
    try {
      final response = await http.get(Uri.parse('http://72.60.241.246:5001/api/Prices/product/${widget.productId}?marketId=${widget.marketId}'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final ascendingData = List<dynamic>.from(data.reversed);
        
        setState(() {
          _priceHistory = ascendingData;
          _isLoading = false;
          _calculateLiveSemaforo();
        });
      } else {
        setState(() {
          _error = "No hay datos recientes.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error al conectar.";
        _isLoading = false;
      });
    }
  }

  void _calculateLiveSemaforo() {
    if (_priceHistory.isEmpty) return;

    _currentPrice = (_priceHistory.last['averagePricePerKg'] as num).toDouble();

    final historyLength = _priceHistory.length < 7 ? _priceHistory.length : 7;
    
    if (historyLength < 2) {
      _recommendation = "MANTENER";
      _recommendationColor = Colors.amber.shade700;
      _recommendationIcon = Icons.trending_flat;
      return;
    }

    final lastDays = _priceHistory.sublist(_priceHistory.length - historyLength);
    double sum = 0;
    for (var p in lastDays) {
      sum += (p['averagePricePerKg'] as num).toDouble();
    }
    _sma7 = sum / historyLength;

    if (_currentPrice > _sma7 + 50) {
      _recommendation = "ESPERAR";
      _recommendationColor = Colors.red.shade600;
      _recommendationIcon = Icons.trending_up;
    } else if (_currentPrice < _sma7 - 50) {
      _recommendation = "COMPRAR";
      _recommendationColor = Colors.green.shade600;
      _recommendationIcon = Icons.trending_down;
    } else {
      _recommendation = "MANTENER";
      _recommendationColor = Colors.amber.shade700;
      _recommendationIcon = Icons.trending_flat;
    }
  }

  Future<void> _registerSaving() async {
    if (_recommendation != "COMPRAR") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solo puedes registrar ahorros si es momento de comprar')));
      return;
    }
    
    // Asumimos compra de 10 KG simulados
    double kilos = 10;
    double savedAmount = (_sma7 - _currentPrice) * kilos;
    
    if (savedAmount <= 0) return;

    try {
      await http.post(
        Uri.parse('http://72.60.241.246:5001/api/Profile/1/savings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': widget.productId,
          'savedAmount': savedAmount,
          'kilosBought': kilos
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Excelente! Has registrado \$${savedAmount.toStringAsFixed(0)} COP ahorrados.')));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.productName),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _error.isNotEmpty 
          ? Center(child: Text(_error))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Precio Promedio Hoy", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  Text("\$${_currentPrice.toStringAsFixed(0)} / KG", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTrafficLightCard(),
                  const SizedBox(height: 30),
                  if (_recommendation == "COMPRAR")
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.savings, color: Colors.white),
                        label: Text('Registrar Compra (10 Kg)', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                        ),
                        onPressed: _registerSaving,
                      ),
                    ),
                  const SizedBox(height: 30),
                  Text("Histórico (30 Días)", style: TextStyle(color: Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200)
                    ),
                    child: _buildChart(),
                  )
                ],
              ),
            )
    );
  }

  Widget _buildTrafficLightCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _recommendationColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _recommendationColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_recommendationIcon, size: 48, color: _recommendationColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Decisión de Compra", style: TextStyle(color: _recommendationColor, fontWeight: FontWeight.bold)),
              Text(_recommendation, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _recommendationColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_priceHistory.isEmpty) return const SizedBox.shrink();

    double minY = double.infinity;
    double maxY = 0;
    for (var p in _priceHistory) {
      double price = (p['averagePricePerKg'] as num).toDouble();
      if (price < minY) minY = price;
      if (price > maxY) maxY = price;
    }
    
    if (minY == maxY) {
      minY = minY - (minY * 0.1);
      maxY = maxY + (maxY * 0.1);
    } else {
      double padding = (maxY - minY) * 0.2;
      minY = minY - padding;
      maxY = maxY + padding;
    }
    if (minY < 0) minY = 0;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            )
          )
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _priceHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['averagePricePerKg'] as num).toDouble())).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}
