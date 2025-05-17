import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';

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
  final VoidCallback? onPressed;

  const CategoriesCard({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: _boxDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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