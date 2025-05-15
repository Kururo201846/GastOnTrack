import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No hay cuenta asociada a este email';
      case 'invalid-email':
        return 'Formato de email inválido';
      default:
        return 'Error al enviar el correo. Intenta nuevamente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'GastOnTrack',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/cerdito.png',
                  height: 160,
                  width: 160,
                ),
                const SizedBox(height: 60),

                if (!_emailSent) ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: AppTheme.primaryBlue,
                      ),
                      border: const UnderlineInputBorder(),
                      hintText: 'Ingresa tu email registrado',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendPasswordResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Enviar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Correo enviado',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Hemos enviado instrucciones para restablecer tu contraseña al email proporcionado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Volver al login',
                        style: TextStyle(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
