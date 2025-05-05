import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherSection extends StatelessWidget {
  const WeatherSection({super.key});

  Future<Map<String, dynamic>> fetchCuaca() async {
    const String apiKey =
        '8fe94eeaa19c586f60566181ea8794b5'; // Ganti dengan API key kamu
    const String city = 'Medan';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city,id&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final suhuSekarang = data['list'][0]['main']['temp'];
      final kondisiBesok = data['list'][8]['weather'][0]['description'];

      return {
        'suhu': suhuSekarang,
        'besok': kondisiBesok,
      };
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCuaca(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          final suhu = snapshot.data!['suhu'].toStringAsFixed(1);
          final ramalan = snapshot.data!['besok'];
          return Row(
            children: [
              Icon(Icons.thermostat, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                "Suhu: $suhu°C",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Icon(Icons.cloud, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                "Besok: $ramalan",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          );
        }
      },
    );
  }
}
