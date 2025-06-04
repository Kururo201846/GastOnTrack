import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _getUserInvoices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final query =
        await FirebaseFirestore.instance
            .collection('boletas')
            .where('uid', isEqualTo: user.uid)
            .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text(
          'Datos de Boleta Obtenidos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUserInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];
          double total = 0.0;

          for (var boleta in data) {
            final productos = boleta['productos'] as List<dynamic>? ?? [];
            for (var producto in productos) {
              final precio =
                  double.tryParse(
                    producto['precio'].toString().replaceAll(
                      RegExp(r'[^0-9.]'),
                      '',
                    ),
                  ) ??
                  0.0;
              total += precio;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 600),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                children: [
                  const Center(
                    child: Text(
                      'Datos de Boleta\nObtenidos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...data.map((boleta) {
                    final categoria = boleta['categoria'] ?? 'Sin categoría';
                    final productos =
                        boleta['productos'] as List<dynamic>? ?? [];

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          'Categoría: $categoria',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Cantidad',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Descripción',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Precio',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1.5),
                          ...productos.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(item['cantidad'].toString()),
                                  ),
                                  Expanded(
                                    child: Text(item['descripcion'].toString()),
                                  ),
                                  Expanded(child: Text('\$${item['precio']}')),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(thickness: 1.5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total\n\$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
