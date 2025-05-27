import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
    _initialized = true;
  }

  static Future<void> showTemperatureAlert(
      String moduleId, double temperature) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'high_temperature_alert',
      'Temperature Alerts',
      channelDescription: 'Alerts for high temperature readings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      moduleId.hashCode, // Unique ID for each module
      'Peringatan Suhu',
      'Suhu ${moduleId.replaceAll('module', 'modul ')} mencapai ${temperature.toStringAsFixed(1)}°C!',
      details,
    );
  }

  static Future<void> checkTemperature(
      String moduleId, double temperature, double moisture) async {
    final prefs = await SharedPreferences.getInstance();
    final tempEnabled = prefs.getBool('tempEnabled') ?? true;
    final moistureEnabled = prefs.getBool('moistureEnabled') ?? true;
    final tempThreshold =
        double.parse(prefs.getString('tempThreshold') ?? '40');
    final moistureThreshold =
        double.parse(prefs.getString('moistureThreshold') ?? '30');

    if (tempEnabled && temperature >= tempThreshold) {
      showTemperatureAlert(moduleId, temperature);
    }

    if (moistureEnabled && moisture <= moistureThreshold) {
      showMoistureAlert(moduleId, moisture);
    }
  }

  static Future<void> showMoistureAlert(
      String moduleId, double moisture) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'low_moisture_alert',
      'Moisture Alerts',
      channelDescription: 'Alerts for low moisture readings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      moduleId.hashCode +
          1, // Unique ID for each module (+1 to differentiate from temperature alerts)
      'Peringatan Kelembaban',
      'Kelembaban ${moduleId.replaceAll('module', 'modul ')} turun ke ${moisture.toStringAsFixed(1)}%!',
      details,
    );
  }
}
