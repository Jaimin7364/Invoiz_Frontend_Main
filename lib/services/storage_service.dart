import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/business_model.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Secure Storage Methods (for sensitive data like tokens)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
  }

  // User Data Storage
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: AppConfig.userKey, value: userJson);
  }

  Future<User?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: AppConfig.userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error getting user from storage: $e');
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  // Business Data Storage
  Future<void> saveBusiness(Business business) async {
    final businessJson = jsonEncode(business.toJson());
    await _secureStorage.write(key: AppConfig.businessKey, value: businessJson);
  }

  Future<Business?> getBusiness() async {
    try {
      final businessJson = await _secureStorage.read(key: AppConfig.businessKey);
      if (businessJson != null && businessJson.isNotEmpty) {
        final businessMap = jsonDecode(businessJson) as Map<String, dynamic>;
        return Business.fromJson(businessMap);
      }
      return null;
    } catch (e) {
      print('Error getting business from storage: $e');
      return null;
    }
  }

  Future<void> deleteBusiness() async {
    await _secureStorage.delete(key: AppConfig.businessKey);
  }

  // Shared Preferences Methods (for non-sensitive data)
  Future<void> saveOnboardingStatus(bool completed) async {
    await _preferences?.setBool(AppConfig.onboardingKey, completed);
  }

  bool getOnboardingStatus() {
    return _preferences?.getBool(AppConfig.onboardingKey) ?? false;
  }

  Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  Future<void> saveDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  List<String> getStringList(String key) {
    return _preferences?.getStringList(key) ?? [];
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clear() async {
    await _preferences?.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Save token timestamp for tracking
  Future<void> saveTokenTimestamp() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _preferences?.setString('token_timestamp', timestamp);
  }

  // Get token timestamp
  Future<DateTime?> getTokenTimestamp() async {
    final timestampStr = _preferences?.getString('token_timestamp');
    if (timestampStr != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(timestampStr));
    }
    return null;
  }

  // Check if token is expired (client-side estimation)
  Future<bool> isTokenExpired() async {
    final timestamp = await getTokenTimestamp();
    if (timestamp == null) return true;
    
    final tokenAge = DateTime.now().difference(timestamp).inDays;
    return tokenAge >= AppConfig.tokenLifetimeDays;
  }

  // Clear all user data (logout)
  Future<void> clearUserData() async {
    await deleteToken();
    await deleteUser();
    await deleteBusiness();
    await _preferences?.remove('token_timestamp');
  }

  // Clear all app data
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await _preferences?.clear();
  }
}