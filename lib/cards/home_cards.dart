import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:gast_on_track/widgets/mini_pie_chart.dart';

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppTheme.shadows,
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class TotalExpensesCard extends StatelessWidget {
  final double amount;
  final VoidCallback? onHistoryPressed;

  const TotalExpensesCard({
    super.key,
    required this.amount,
    this.onHistoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _boxDecoration(),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
        child: Column(
          children: [
            Text(
              '\$${amount.toStringAsFixed(0)} CLP',
              style: TextStyle(
                fontSize: 32,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Gastos totales',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: AppTheme.shadows),
            const SizedBox(height: 10),
            InkWell(
              onTap: onHistoryPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Historial',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.receipt_long, 
                        size: 20, 
                        color: AppTheme.textPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesCard extends StatelessWidget {
  final Map<String, double> gastosPorCategoria;
  final double totalMes;

  const CategoriesCard({
    super.key,
    required this.gastosPorCategoria,
    required this.totalMes,
  });

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'comida':
        return Colors.green;
      case 'tecnologia':
        return Colors.blue;
      case 'gastos':
        return Colors.orange;
      case 'otros':
        return Colors.grey;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = gastosPorCategoria.keys.toList();
    return Container(
      width: double.infinity,
      decoration: _boxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Categorías',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: categorias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (context, index) {
                    final cat = categorias[index];
                    final porcentaje = totalMes > 0
                        ? (gastosPorCategoria[cat]! / totalMes) * 100
                        : 0.0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MiniPieChart(
                          porcentaje: porcentaje,
                          colorPrincipal: _getColorForCategory(cat),
                          colorSecundario: Colors.grey[300]!,
                          label: cat,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${cat[0].toUpperCase()}${cat.substring(1)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onPressed;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _boxDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 30, color: AppTheme.primaryBlue),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, 
                  size: 16, 
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}