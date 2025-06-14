import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': '¡Recuerda registrar tus gastos!',
        'body': 'No olvides anotar tus compras del día para llevar un mejor control.',
        'icon': Icons.edit_note,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': '¿Ya revisaste tu presupuesto?',
        'body': 'Consulta el gráfico mensual para ver en qué categoría gastas más.',
        'icon': Icons.pie_chart,
        'color': Colors.green,
      },
      {
        'title': '¡Felicitaciones!',
        'body': 'Has registrado gastos por 7 días seguidos. ¡Sigue así!',
        'icon': Icons.emoji_events,
        'color': Colors.orange,
      },
      {
        'title': 'Consejo de ahorro',
        'body': 'Intenta usar la ruleta antes de un gasto impulsivo. ¡Te puede ayudar a decidir!',
        'icon': Icons.casino,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppTheme.cream,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            color: notif['color'].withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notif['color'].withOpacity(0.2),
                child: Icon(notif['icon'], color: notif['color']),
              ),
              title: Text(
                notif['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notif['body']),
            ),
          );
        },
      ),
    );
  }
}