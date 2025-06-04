import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class ManualInvoiceScreen extends StatefulWidget {
  const ManualInvoiceScreen({super.key});

  @override
  State<ManualInvoiceScreen> createState() => _ManualInvoiceScreenState();
}

class _ManualInvoiceScreenState extends State<ManualInvoiceScreen> {
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  List<Map<String, dynamic>> productos = [];
  String? categoriaSeleccionada;
  bool _isSubmitting = false;

  final List<String> categorias = ['Comida', 'Tecnología', 'Gastos', 'Otros'];

  void _agregarProducto() {
    final cantidad = _cantidadController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precio = _precioController.text.trim();

    if (cantidad.isEmpty || descripcion.isEmpty || precio.isEmpty) return;

    setState(() {
      productos.add({
        'cantidad': cantidad,
        'descripcion': descripcion,
        'precio': precio,
      });
      _cantidadController.clear();
      _descripcionController.clear();
      _precioController.clear();
    });
  }

  void _guardarBoleta() async {
    if (_isSubmitting || productos.isEmpty || categoriaSeleccionada == null)
      return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('boletas').add({
        'uid': user.uid,
        'productos': productos,
        'categoria': categoriaSeleccionada,
        'fecha': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boleta registrada con éxito')),
      );

      setState(() {
        productos.clear();
        categoriaSeleccionada = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la boleta: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        iconTheme: IconThemeData(color: AppTheme.primaryBlue),
        title: Text(
          'Registro manual de boleta',
          style: TextStyle(color: AppTheme.primaryBlue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              value: categoriaSeleccionada,
              onChanged:
                  (value) => setState(() => categoriaSeleccionada = value),
              items:
                  categorias
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agregarProducto,
              child: const Text('Agregar producto'),
            ),
            const SizedBox(height: 10),
            ...productos.map(
              (p) => ListTile(
                title: Text('${p['descripcion']} x${p['cantidad']}'),
                subtitle: Text('Precio: \$${p['precio']}'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isSubmitting ? null : _guardarBoleta,
              child: const Text(
                'Guardar boleta',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
