import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey = '8fe94eeaa19c586f60566181ea8794b5'; // Get from openweathermap.org
  final String city = 'Banjarmasin'; // Change to your city
  final String country = 'ID';

  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city,$country&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['list'][0];
        final tomorrow = data['list'][8]; // Forecast for tomorrow (24 hours ahead)

        return {
          'suhuTerkini': current['main']['temp'].round().toString(),
          'ramalanBesok': _mapWeatherDescription(tomorrow['weather'][0]['main']),
          'iconBesok': tomorrow['weather'][0]['icon'],
        };
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error getting weather data: $e');
      return {
        'suhuTerkini': 'N/A',
        'ramalanBesok': 'Tidak tersedia',
        'iconBesok': '01d',
      };
    }
  }

  String _mapWeatherDescription(String englishDesc) {
    final Map<String, String> weatherMap = {
      'Clear': 'Cerah',
      'Clouds': 'Berawan',
      'Rain': 'Hujan',
      'Drizzle': 'Gerimis',
      'Thunderstorm': 'Badai Petir',
      'Snow': 'Salju',
      'Mist': 'Berkabut',
      'Fog': 'Berkabut Tebal',
    };
    return weatherMap[englishDesc] ?? englishDesc;
  }
}