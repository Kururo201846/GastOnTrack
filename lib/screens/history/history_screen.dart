import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Productos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('boletas')
            .where('uid', isEqualTo: user.uid)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> productos = [];

          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final fecha = data['fecha'];
            final productosBoleta = (data['productos'] is List)
                ? data['productos'] as List<dynamic>
                : [];
            for (final producto in productosBoleta) {
              productos.add({
                'descripcion': producto is Map && producto.containsKey('descripcion')
                    ? producto['descripcion']
                    : 'Sin descripción',
                'precio': producto is Map && producto.containsKey('precio')
                    ? producto['precio']
                    : 0,
                'fecha': fecha,
              });
            }
          }

          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados'));
          }

          productos.sort((a, b) {
            final fa = a['fecha'];
            final fb = b['fecha'];
            if (fa is Timestamp && fb is Timestamp) {
              return fb.compareTo(fa);
            }
            return 0;
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: productos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = productos[index];
              final fecha = item['fecha'];
              String fechaStr = '';
              if (fecha is Timestamp) {
                final dt = fecha.toDate();
                fechaStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
              }
              return ListTile(
                title: Text(item['descripcion'].toString()),
                subtitle: Text(fechaStr),
                trailing: Text('\$${item['precio']}'),
              );
            },
          );
        },
      ),
    );
  }
}