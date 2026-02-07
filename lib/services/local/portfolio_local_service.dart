import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/*
  Portfolio Local Service.
  
  Handles local caching of portfolio data using SharedPreferences.
  Structure:
  - Key: 'portfolio_cache_<userId>'
  - Value: JSON String of Portfolio Data
*/

class PortfolioLocalService {
  static const String _prefix = 'portfolio_cache_';

  Future<void> cachePortfolio(String userId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefix$userId';

      // Add timestamp to data effectively if needed, but for now we just store raw data
      // We might want to store a wrapper: { 'timestamp': ..., 'data': ... }
      final cacheObject = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

      await prefs.setString(key, jsonEncode(cacheObject));
    } catch (e) {
      print('Cache Write Error: $e');
    }
  }

  Future<Map<String, dynamic>?> getCachedPortfolio(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefix$userId';
      final jsonStr = prefs.getString(key);

      if (jsonStr == null) return null;

      final cacheObject = jsonDecode(jsonStr) as Map<String, dynamic>;
      // Optional: Check timestamp validity (e.g. expire after 24 hours)
      // For now, return what we have to show *something* instantly, even if old.
      // The network fetch will update it anyway.

      return cacheObject['data'] as Map<String, dynamic>;
    } catch (e) {
      print('Cache Read Error: $e');
      return null;
    }
  }

  Future<void> clearCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$userId';
    await prefs.remove(key);
  }
}
