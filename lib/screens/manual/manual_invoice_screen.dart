import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'package:intl/intl.dart';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
    if (_isSubmitting || productos.isEmpty || categoriaSeleccionada == null) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    String? imageBase64;
    try {
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      await FirebaseFirestore.instance.collection('boletas').add({
        'uid': user.uid,
        'productos': productos,
        'categoria': categoriaSeleccionada,
        'fecha': Timestamp.now(),
        'imagenBase64': imageBase64,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boleta registrada con éxito')),
      );

      setState(() {
        productos.clear();
        categoriaSeleccionada = null;
        _selectedImage = null;
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppTheme.primaryBlue),
        title: Text(
          'Registro manual de boleta',
          style: TextStyle(color: AppTheme.primaryBlue),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Categoría',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black),
            ),
            dropdownColor: Colors.white,
            value: categoriaSeleccionada,
            onChanged: (value) => setState(() => categoriaSeleccionada = value),
            items: categorias.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descripcionController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Descripción',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Precio',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Imagen de la boleta:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          if (_selectedImage != null)
            Image.file(_selectedImage!, height: 120),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Seleccionar imagen'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _agregarProducto,
            child: const Text('Agregar producto'),
          ),
          const SizedBox(height: 20),
          ...productos.map((p) {
            final precioFormateado = formatter.format(
              double.tryParse(p['precio'].toString()) ?? 0,
            );
            return ListTile(
              title: Text('${p['descripcion']} x${p['cantidad']}'),
              subtitle: Text('Precio: $precioFormateado CLP'),
            );
          }),
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
    );
  }
}
