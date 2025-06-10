import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class MiniPieChart extends StatelessWidget {
  final double porcentaje;
  final Color colorPrincipal;
  final Color colorSecundario;
  final String label;

  const MiniPieChart({
    super.key,
    required this.porcentaje,
    required this.colorPrincipal,
    required this.colorSecundario,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 75,
          height: 75,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 18,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  value: porcentaje,
                  color: AppTheme.primaryBlue,
                  radius: 16,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 100 - porcentaje,
                  color: colorSecundario,
                  radius: 16,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        Text(
          '${porcentaje.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class CategoriesCard extends StatelessWidget {
  final List<Map<String, dynamic>> gastosPorCategoria;
  final double totalMes;

  const CategoriesCard({
    super.key,
    required this.gastosPorCategoria,
    required this.totalMes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gastos por Categoría',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ...gastosPorCategoria.map(
              (gasto) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(gasto['categoria']),
                    const SizedBox(width: 10),
                    MiniPieChart(
                      porcentaje: gasto['porcentaje'],
                      colorPrincipal: gasto['colorPrincipal'],
                      colorSecundario: gasto['colorSecundario'],
                      label: gasto['categoria'],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '\$${gasto['monto'].toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total del Mes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${totalMes.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}