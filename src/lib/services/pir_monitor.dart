// lib/services/pir_monitor.dart

class PirMonitor {
  final APIClient client;
  Timer? _monitorTimer;

  PirMonitor(this.client);

  void startMonitoring() {
    _monitorTimer =
        Timer.periodic(Duration(seconds: 1), (_) => _checkPirStatus());
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
  }

  Future<void> _checkPirStatus() async {
    try {
      final entities = await client.list_entities_services();
      for (var entityList in entities) {
        for (var entity in entityList) {
          if (entity is BinarySensorInfo && entity.name == "PIR_PF") {
            if (entity.state) {
              _showPirNotification();
            }
          }
        }
      }
    } catch (e) {
      print('PIR monitoring error: $e');
    }
  }

  Future<void> _showPirNotification() async {
    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidDetails = AndroidNotificationDetails(
      'pet_feeder',
      'Pet Feeder',
      importance: Importance.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await notificationsPlugin.show(
        0, 'Pet Detected', 'Your pet is at the feeder', details);
  }
}
