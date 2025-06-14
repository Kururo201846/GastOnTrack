import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Ruleta usada
    final ruletaHistory = prefs.getStringList('rouletteHistory') ?? [];
    final ruletaCount = ruletaHistory.length;

    // 2. Contar 3 "NO" seguidos
    int consecutivosNo = 0;
    for (final entry in ruletaHistory.reversed) {
      if (entry.contains('NO')) {
        consecutivosNo++;
        if (consecutivosNo >= 3) break;
      } else {
        consecutivosNo = 0;
      }
    }

    // 3. Boletas registradas (simulado aquí, puedes conectar a Firestore)
    final int boletasRegistradas = prefs.getInt('boletasRegistradas') ?? 1;

    // 4. Historial visto
    final int historialCount = prefs.getInt('historialVisto') ?? 0;
    print('Historial visto: $historialCount');

    setState(() {
      achievements = [
        {
          'title': 'Primer boleta',
          'description': 'Registraste tu primera boleta',
          'current': boletasRegistradas,
          'goal': 1,
        },
        {
          'title': 'Capricho controlado',
          'description': 'Dijiste NO a la ruleta 3 veces seguidas',
          'current': consecutivosNo,
          'goal': 3,
        },
        {
          'title': 'Ruleta responsable',
          'description': 'Usaste la ruleta 5 veces',
          'current': ruletaCount,
          'goal': 5,
        },
        {
          'title': 'Historial revisado',
          'description': 'Consultaste tu historial 10 veces',
          'current': historialCount,
          'goal': 10,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAchievements, // ✅ Botón para recargar datos
          ),
        ],
      ),
      body:
          achievements.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: achievements.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final a = achievements[index];
                  final progress = (a['current'] / a['goal']).clamp(0.0, 1.0);
                  final unlocked = a['current'] >= a['goal'];

                  return GestureDetector(
                    onTap: () {
                      if (unlocked) {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                content: Text('¡${a['description']}!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black12,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  color: unlocked ? Colors.green : Colors.grey,
                                ),
                              ),
                              Icon(
                                Icons.emoji_events,
                                size: 32,
                                color: unlocked ? Colors.amber : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            a['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: unlocked ? Colors.black : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            a['description'],
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${a['current']}/${a['goal']}',
                            style: const TextStyle(fontSize: 11),
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
