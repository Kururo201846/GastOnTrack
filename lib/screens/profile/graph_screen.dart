import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'dart:math';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  Map<String, double> gastosPorCategoria = {};
  bool isLoading = true;
  String mesActual = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_CL', null).then((_) {
      setState(() {
        mesActual = DateFormat('MMMM', 'es_CL').format(DateTime.now());
      });
      _cargarDatos();
    });
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
      final fecha = (boleta['fecha'] as Timestamp?)?.toDate();
      if (fecha == null ||
          DateFormat('MMMM', 'es_CL').format(fecha) != mesActual)
        continue;

      final categoriaOriginal = boleta['categoria'] ?? 'otros';
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

  List<PieChartSectionData> _buildPieSections() {
    final total = gastosPorCategoria.values.fold(0.0, (a, b) => a + b);
    return gastosPorCategoria.entries.map((entry) {
      final porcentaje = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${porcentaje.toStringAsFixed(1)}%',
        color: _getColorForCategory(entry.key),
        radius: porcentaje > 90 ? 110 : 90,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Gastos de ${toBeginningOfSentenceCase(mesActual)}'),
        backgroundColor: AppTheme.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen mensual - ${toBeginningOfSentenceCase(mesActual)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(),
                          centerSpaceRadius: 50,
                          sectionsSpace: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children:
                          gastosPorCategoria.entries.map((entry) {
                            final total = gastosPorCategoria.values.fold(
                              0.0,
                              (a, b) => a + b,
                            );
                            final porcentaje = (entry.value / total) * 100;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: _getColorForCategory(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text('${porcentaje.toStringAsFixed(2)} %'),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${entry.value.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} CLP',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
    );
  }
}
