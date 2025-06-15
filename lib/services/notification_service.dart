import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static bool _initialized = false;
  static List<StreamSubscription<DatabaseEvent>> _subscriptions = [];

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
    setupModuleListeners();
  }

  static void setupModuleListeners() {
    // Hapus listener yang ada sebelumnya
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Setup listener untuk setiap modul
    for (int i = 1; i <= 3; i++) {
      final moduleRef = _database.child('modules/module$i');
      var subscription = moduleRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          _checkModuleValues(i, data);
        }
      });
      _subscriptions.add(subscription);
    }
  }

  static Future<void> _checkModuleValues(
      int moduleNumber, Map<String, dynamic> data) async {
    final temperature = data['temperature'] as double;
    final humidity = data['humidity'] as double;

    final prefs = await SharedPreferences.getInstance();
    final tempEnabled = prefs.getBool('tempEnabled') ?? true;
    final humidityEnabled = prefs.getBool('moistureEnabled') ?? true;
    final tempThreshold =
        double.parse(prefs.getString('tempThreshold') ?? '40');
    final humidityThreshold =
        double.parse(prefs.getString('moistureThreshold') ?? '30');

    if (tempEnabled && temperature > tempThreshold) {
      await showTemperatureAlert('module$moduleNumber', temperature);
    }

    if (humidityEnabled && humidity > humidityThreshold) {
      await showHumidityAlert('module$moduleNumber', humidity);
    }
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
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final moduleNumber = moduleId.replaceAll('module', '');

    await _notifications.show(
      int.parse(moduleNumber), // Menggunakan nomor modul sebagai ID notifikasi
      'Peringatan Suhu Modul $moduleNumber',
      'Modul $moduleNumber mengalami kenaikan suhu: ${temperature.toStringAsFixed(1)}°C',
      details,
    );
  }

  static Future<void> showHumidityAlert(
      String moduleId, double humidity) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'high_humidity_alert',
      'Humidity Alerts',
      channelDescription: 'Alerts for high humidity readings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final moduleNumber = moduleId.replaceAll('module', '');

    await _notifications.show(
      int.parse(moduleNumber) +
          100, // Menggunakan nomor modul + 100 untuk membedakan dengan notifikasi suhu
      'Peringatan Kelembaban Modul $moduleNumber',
      'Modul $moduleNumber mengalami kenaikan kelembaban: ${humidity.toStringAsFixed(1)}%',
      details,
    );
  }

  static void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
