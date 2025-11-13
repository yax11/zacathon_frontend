import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class OverviewController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  final accounts = <AccountModel>[].obs;
  final transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final userData = await _authRepository.getCurrentUser();
      if (userData != null) {
        user.value = userData;
        accounts.value = userData.accounts;
        transactions.value = userData.transactions;
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    // Refresh from API
    await _authRepository.refreshUserData();
    await loadUserData();
  }
}

