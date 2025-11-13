import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/local/biometric_service.dart';
import '../../../core/constants/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final BiometricService _biometricService = BiometricService();

  final isLoading = false.obs;
  final isBiometricLoading = false.obs;
  final isBiometricAvailable = false.obs;
  final isPasswordVisible = false.obs;
  final savedAccountNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkBiometricAvailability();
    // Load saved account number eagerly
    loadSavedAccountNumber();
  }

  Future<void> loadSavedAccountNumber() async {
    try {
      final accountNumber = await _authRepository.getSavedAccountNumber();
      if (accountNumber != null) {
        savedAccountNumber.value = accountNumber;
      }
    } catch (e) {
      // Handle any errors gracefully
      print('Error loading saved account number: $e');
    }
  }

  Future<void> checkBiometricAvailability() async {
    isBiometricAvailable.value = await _biometricService.isAvailable();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login({
    required String accountNumber,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      
      final result = await _authRepository.login(
        accountNumber: accountNumber,
        password: password,
      );

      if (result['success'] == true) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Login failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (result['success'] == true) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Registration failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithBiometrics() async {
    try {
      isBiometricLoading.value = true;
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access your account',
      );

      if (authenticated) {
        // Check if user data exists
        final user = await _authRepository.getCurrentUser();
        if (user != null && _authRepository.isLoggedIn()) {
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          Get.snackbar(
            'Error',
            'Please login with your credentials first',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
      } else {
        Get.snackbar(
          'Authentication Failed',
          'Biometric authentication was cancelled or failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Biometric authentication failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isBiometricLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => _authRepository.isLoggedIn();
}

