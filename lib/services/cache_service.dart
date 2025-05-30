import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const cacheTimeout = Duration(minutes: 5);

  // Menyimpan data ke cache
  Future<void> cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  // Mengambil data dari cache
  Future<T?> getCachedData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return null;
      
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
      
      // Cek apakah cache sudah expired
      if (DateTime.now().difference(timestamp) > cacheTimeout) {
        await removeCachedData(key);
        return null;
      }
      
      return fromJson(json['data'] as Map<String, dynamic>);
    } catch (e) {
      print('Error reading cache: $e');
      return null;
    }
  }

  // Menghapus data dari cache
  Future<void> removeCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Error removing cache: $e');
    }
  }

  // Mengecek apakah cache masih valid
  Future<bool> isCacheValid(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return false;
      
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
      
      return DateTime.now().difference(timestamp) <= cacheTimeout;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  // Clear semua cache
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
