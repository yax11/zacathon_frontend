import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      symbol: showSymbol ? AppConstants.currency : '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format date
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  // Hide sensitive data (like account numbers)
  static String hideSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) return data;
    final visible = data.substring(0, visibleChars);
    final hidden = '*' * (data.length - visibleChars);
    return '$visible$hidden';
  }

  // Format account number
  static String formatAccountNumber(String accountNumber) {
    if (accountNumber.length < 8) return accountNumber;
    final visible = accountNumber.substring(0, 8);
    final hidden = '*' * (accountNumber.length - 8);
    return '$visible$hidden';
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number (Nigerian format)
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^(\+?234|0)?[789]\d{9}$').hasMatch(phone);
  }

  // Validate account number
  static bool isValidAccountNumber(String accountNumber) {
    return RegExp(r'^\d{10}$').hasMatch(accountNumber);
  }
}

