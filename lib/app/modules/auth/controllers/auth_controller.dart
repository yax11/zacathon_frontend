import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/local/biometric_service.dart';
import '../../../core/constants/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final BiometricService _biometricService = BiometricService();

  final isLoading = false.obs;
  final isBiometricAvailable = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkBiometricAvailability();
  }

  Future<void> checkBiometricAvailability() async {
    isBiometricAvailable.value = await _biometricService.isAvailable();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate login success for now (skip API call)
      // TODO: Replace with actual API call when backend is ready
      // final result = await _authRepository.login(
      //   email: email,
      //   password: password,
      // );

      // Simulate successful login
      Get.offAllNamed(AppRoutes.dashboard);
      
      // Original API code (commented out for simulation)
      // if (result['success'] == true) {
      //   Get.offAllNamed(AppRoutes.dashboard);
      // } else {
      //   Get.snackbar(
      //     'Error',
      //     result['message'] ?? 'Login failed',
      //     snackPosition: SnackPosition.BOTTOM,
      //   );
      // }
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
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access your account',
      );

      if (authenticated) {
        // Simulate successful login (skip API check for now)
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.dashboard);
        
        // Original code (commented out for simulation)
        // // Check if user data exists
        // final user = _authRepository.getCurrentUser();
        // if (user != null && _authRepository.isLoggedIn()) {
        //   Get.offAllNamed(AppRoutes.dashboard);
        // } else {
        //   Get.snackbar(
        //     'Error',
        //     'Please login with your credentials first',
        //     snackPosition: SnackPosition.BOTTOM,
        //   );
        // }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Biometric authentication failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => _authRepository.isLoggedIn();
}

