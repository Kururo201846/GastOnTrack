import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  Map<String, double> gastosPorCategoria = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query =
        await FirebaseFirestore.instance
            .collection('boletas')
            .where('uid', isEqualTo: user.uid)
            .get();

    final data = query.docs.map((doc) => doc.data()).toList();

    final Map<String, double> acumulado = {};

    for (var boleta in data) {
      final categoriaOriginal = boleta['categoria'] ?? 'Otros';
      final categoria = _normalizarTexto(categoriaOriginal);
      final productos = boleta['productos'] as List<dynamic>? ?? [];

      for (var p in productos) {
        final precio = double.tryParse(p['precio'].toString()) ?? 0.0;
        acumulado[categoria] = (acumulado[categoria] ?? 0) + precio;
      }
    }

    setState(() {
      gastosPorCategoria = acumulado;
      isLoading = false;
    });
  }

  List<BarChartGroupData> _buildBarGroups() {
    final keys = gastosPorCategoria.keys.toList();
    return List.generate(keys.length, (index) {
      final cat = keys[index];
      final value = gastosPorCategoria[cat]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getColorForCategory(cat),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'comida':
        return AppTheme.primaryBlue;
      case 'tecnologia':
        return AppTheme.darkGreen;
      case 'gastos':
        return AppTheme.accentGreen;
      case 'otros':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('Gráficas por Categoría'),
        backgroundColor: AppTheme.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Total de Gastos por Categoría',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: _buildBarGroups(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < gastosPorCategoria.length) {
                                    return Text(
                                      gastosPorCategoria.keys.elementAt(index),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}