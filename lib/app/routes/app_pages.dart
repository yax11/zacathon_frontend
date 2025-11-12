import 'package:get/get.dart';
import '../core/constants/app_routes.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/overview/views/overview_view.dart';
import '../modules/airtime/views/airtime_view.dart';
import '../modules/zai/views/zai_view.dart';
import '../modules/zai/bindings/zai_binding.dart';
import '../modules/transfer/views/transfer_view.dart';
import '../modules/bills/views/bills_view.dart';
import '../modules/transactions/views/transaction_history_view.dart';
import '../modules/receipt/views/receipt_view.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    // Auth Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    // Dashboard Route
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // Menu Routes
    GetPage(
      name: AppRoutes.overview,
      page: () => const OverviewView(),
    ),
    GetPage(
      name: AppRoutes.airtime,
      page: () => const AirtimeView(),
    ),
    GetPage(
      name: AppRoutes.zai,
      page: () => const ZaiView(),
      binding: ZaiBinding(),
    ),
    GetPage(
      name: AppRoutes.transfer,
      page: () => const TransferView(),
    ),
    GetPage(
      name: AppRoutes.bills,
      page: () => const BillsView(),
    ),
    GetPage(
      name: AppRoutes.transactionHistory,
      page: () => const TransactionHistoryView(),
    ),
    GetPage(
      name: AppRoutes.receipt,
      page: () => const ReceiptView(),
    ),
  ];
}

