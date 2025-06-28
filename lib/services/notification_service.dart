import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static bool _initialized = false;
  static List<StreamSubscription<DatabaseEvent>> _subscriptions = [];
  static StreamSubscription<DatabaseEvent>? _settingsSubscription;

  // Default settings
  static bool tempEnabled = true;
  static bool humidityEnabled = true;
  static double tempThreshold = 40;
  static double humidityThreshold = 30;
  static double tempMinNormal = 25;
  static double tempMaxNormal = 35;
  static double humidityMinNormal = 60;
  static double humidityMaxNormal = 80;

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

    // Listen to notification_settings from Firebase
    _settingsSubscription =
        _database.child('notification_settings').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        tempEnabled = data['tempEnabled'] ?? true;
        humidityEnabled = data['humidityEnabled'] ?? true;
        tempThreshold = (data['tempThreshold'] ?? 40).toDouble();
        humidityThreshold = (data['humidityThreshold'] ?? 30).toDouble();
        tempMinNormal = (data['tempMinNormal'] ?? 25).toDouble();
        tempMaxNormal = (data['tempMaxNormal'] ?? 35).toDouble();
        humidityMinNormal = (data['humidityMinNormal'] ?? 60).toDouble();
        humidityMaxNormal = (data['humidityMaxNormal'] ?? 80).toDouble();
      }
    });

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
    final temperature = (data['temperature'] as num).toDouble();
    final humidity = (data['humidity'] as num).toDouble();

    if (tempEnabled && temperature > tempThreshold) {
      await showTemperatureAlert('module$moduleNumber', temperature);
    }

    if (humidityEnabled && humidity > humidityThreshold) {
      await showHumidityAlert('module$moduleNumber', humidity);
    }

    // Anda bisa menggunakan tempMinNormal, tempMaxNormal, humidityMinNormal, humidityMaxNormal
    // untuk validasi/range normal di fitur lain jika diperlukan.
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
      int.parse(moduleNumber) + 100, // ID notifikasi berbeda dengan suhu
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
    _settingsSubscription?.cancel();
  }
}
