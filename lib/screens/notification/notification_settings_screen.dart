import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import '../main/components/side_menu.dart';
import '../dashboard/components/header.dart';
import '../../../constants.dart';
import 'package:intl/intl.dart';
import 'package:admin/screens/history/history_screen.dart' show kPrimaryColor;
import 'package:firebase_database/firebase_database.dart';

const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Existing controllers for alert thresholds
  final _temperatureController = TextEditingController(text: '40');
  final _humidityController = TextEditingController(text: '30');

  // New controllers for normal ranges
  final _tempMinController = TextEditingController(text: '25');
  final _tempMaxController = TextEditingController(text: '35');
  final _humidityMinController = TextEditingController(text: '60');
  final _humidityMaxController = TextEditingController(text: '80');

  bool _temperatureEnabled = true;
  bool _humidityEnabled = true;

  @override
  void initState() {
    super.initState();
    _listenSettings();
  }

  void _listenSettings() {
    final dbRef = FirebaseDatabase.instance.ref();
    dbRef.child('notification_settings').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _temperatureEnabled = data['tempEnabled'] ?? true;
          _humidityEnabled = data['humidityEnabled'] ?? true;
          _temperatureController.text =
              (data['tempThreshold'] ?? 40).toString();
          _humidityController.text =
              (data['humidityThreshold'] ?? 30).toString();
          _tempMinController.text = (data['tempMinNormal'] ?? 25).toString();
          _tempMaxController.text = (data['tempMaxNormal'] ?? 35).toString();
          _humidityMinController.text =
              (data['humidityMinNormal'] ?? 60).toString();
          _humidityMaxController.text =
              (data['humidityMaxNormal'] ?? 80).toString();
        });
      }
    });
  }

  Future<void> _saveSettings() async {
    double tempMin = double.tryParse(_tempMinController.text) ?? 0;
    double tempMax = double.tryParse(_tempMaxController.text) ?? 0;
    double humidityMin = double.tryParse(_humidityMinController.text) ?? 0;
    double humidityMax = double.tryParse(_humidityMaxController.text) ?? 0;

    if (tempMin > tempMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Min suhu tidak boleh lebih besar dari Max suhu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (humidityMin > humidityMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Min kelembaban tidak boleh lebih besar dari Max kelembaban'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref();
    await dbRef.child('notification_settings').set({
      'tempEnabled': _temperatureEnabled,
      'humidityEnabled': _humidityEnabled,
      'tempThreshold': double.parse(_temperatureController.text),
      'humidityThreshold': double.parse(_humidityController.text),
      'tempMinNormal': tempMin,
      'tempMaxNormal': tempMax,
      'humidityMinNormal': humidityMin,
      'humidityMaxNormal': humidityMax,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan'),
        backgroundColor: Color(0xFF3A7D44),
      ),
    );
  }

  Widget _buildRangeSettingCard({
    required String title,
    required IconData icon,
    required bool isEnabled,
    required Function(bool) onChanged,
    required TextEditingController alertController,
    required TextEditingController minController,
    required TextEditingController maxController,
    required String suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF5F6FA),
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A7D44).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(icon, color: const Color(0xFF3A7D44), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2D3E),
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: isEnabled,
                      onChanged: onChanged,
                      activeColor: const Color(0xFF3A7D44),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batas Peringatan $title',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: alertController,
                        enabled: isEnabled,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Nilai batas peringatan',
                          suffixText: suffix,
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF3A7D44)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Range Normal $title',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minController,
                              enabled: isEnabled,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Min',
                                suffixText: suffix,
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF3A7D44)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[200]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: maxController,
                              enabled: isEnabled,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Max',
                                suffixText: suffix,
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF3A7D44)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[200]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDateTimesForModule(BuildContext context, int moduleNum) {
    DateTime? latestDate;
    // Cari date terbaru untuk moduleNum
    for (int index = 0; index < 15; index++) {
      final date = DateTime.now().subtract(Duration(minutes: index * 5));
      final modNum = (index % 3) + 1;
      if (modNum == moduleNum) {
        if (latestDate == null || date.isAfter(latestDate)) {
          latestDate = date;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Date/Time Terbaru untuk Module $moduleNum',
          style: const TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: latestDate == null
              ? const Text(
                  'Tidak ada data.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                )
              : ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.calendar_today, color: kPrimaryColor),
                  title: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(latestDate),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: kPrimaryColor,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isDesktop(context))
                const Expanded(flex: 1, child: SideMenu()),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Header(title: "Pengaturan Notifikasi"),
                      const SizedBox(height: defaultPadding),
                      Container(
                        padding: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRangeSettingCard(
                              title: 'Suhu',
                              icon: Icons.thermostat,
                              isEnabled: _temperatureEnabled,
                              onChanged: (value) => setState(() {
                                _temperatureEnabled = value;
                              }),
                              alertController: _temperatureController,
                              minController: _tempMinController,
                              maxController: _tempMaxController,
                              suffix: '°C',
                            ),
                            _buildRangeSettingCard(
                              title: 'Kelembaban Udara',
                              icon: Icons.water_drop,
                              isEnabled: _humidityEnabled,
                              onChanged: (value) => setState(() {
                                _humidityEnabled = value;
                              }),
                              alertController: _humidityController,
                              minController: _humidityMinController,
                              maxController: _humidityMaxController,
                              suffix: '%',
                            ),
                            const SizedBox(height: defaultPadding),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A7D44),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.save, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Simpan Pengaturan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
