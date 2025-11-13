import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // User data keys
  static const String _userDataKey = 'user_data';
  static const String _accountNumberKey = 'account_number';

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _storage.write(key: _userDataKey, value: jsonString);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = await _storage.read(key: _userDataKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Save account number (11 digits)
  Future<void> saveAccountNumber(String accountNumber) async {
    try {
      await _storage.write(key: _accountNumberKey, value: accountNumber);
    } catch (e) {
      throw Exception('Failed to save account number: $e');
    }
  }

  // Get saved account number
  Future<String?> getAccountNumber() async {
    try {
      return await _storage.read(key: _accountNumberKey);
    } catch (e) {
      // Return null on error instead of throwing
      print('Error reading account number from secure storage: $e');
      return null;
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear secure storage: $e');
    }
  }

  // Delete specific key
  Future<void> deleteKey(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete key: $e');
    }
  }
}

