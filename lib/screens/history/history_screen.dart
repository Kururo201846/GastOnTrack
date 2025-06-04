import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<CategoryGroup>> _getTransactions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      final grouped = <String, List<Transaction>>{};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final category = data['category']?.toString() ?? 'Sin categoría';
        final amount = _parseAmount(data['amount']);
        final date = _parseDate(data['date']);
        
        grouped.putIfAbsent(category, () => []);
        grouped[category]!.add(Transaction(
          description: data['description']?.toString() ?? 'Sin descripción',
          amount: amount,
          date: date,
          id: doc.id,
        ));
      }

      return grouped.entries.map((entry) => CategoryGroup(
        category: entry.key,
        icon: _getCategoryIcon(entry.key),
        transactions: entry.value,
      )).toList();
    } catch (e) {
      debugPrint('Error obteniendo transacciones: $e');
      return [];
    }
  }

  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is int) return amount.toDouble();
    if (amount is double) return amount;
    if (amount is String) return double.tryParse(amount) ?? 0.0;
    return 0.0;
  }

  String _parseDate(dynamic date) {
    if (date == null) return 'Fecha desconocida';
    if (date is Timestamp) return _formatTimestamp(date);
    if (date is DateTime) return _formatDateTime(date);
    if (date is String) return date;
    return 'Fecha inválida';
  }

  String _formatTimestamp(Timestamp timestamp) {
    return _formatDateTime(timestamp.toDate());
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    return switch (lowerCategory) {
      'comida' => Icons.restaurant,
      'transporte' => Icons.directions_car,
      'entretenimiento' => Icons.movie,
      'servicios' => Icons.house,
      'salud' => Icons.medical_services,
      _ => Icons.category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Gastos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<CategoryGroup>>(
        future: _getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar transacciones',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay transacciones registradas',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final categories = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final total = category.totalAmount;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ExpansionTile(
                  leading: Icon(category.icon, color: AppTheme.primaryBlue),
                  title: Text(
                    category.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${category.transactions.length} transacciones',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  trailing: Text(
                    '\$${total.toStringAsFixed(0)} CLP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          ...category.transactions.map((transaction) => TransactionTile(
                                transaction: transaction,
                                onTap: () => _showTransactionDetails(context, transaction),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monto: \$${transaction.amount.toStringAsFixed(0)} CLP'),
            Text('Fecha: ${transaction.date}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String description;
  final double amount;
  final String date;
  final String id;

  Transaction({
    required this.description,
    required this.amount,
    required this.date,
    required this.id,
  });
}

class CategoryGroup {
  final String category;
  final IconData icon;
  final List<Transaction> transactions;

  CategoryGroup({
    required this.category,
    required this.icon,
    required this.transactions,
  });

  double get totalAmount => transactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      );
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.receipt,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        transaction.date,
        style: TextStyle(color: AppTheme.textSecondary),
      ),
      trailing: Text(
        '\$${transaction.amount.toStringAsFixed(0)} CLP',
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}