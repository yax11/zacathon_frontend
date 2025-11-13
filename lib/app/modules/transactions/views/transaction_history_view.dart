import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/helpers.dart';
import '../../overview/controllers/overview_controller.dart';

class TransactionHistoryView extends GetView<OverviewController> {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh user data when view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });

    bool _isBalanceVisible = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            Get.back();
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textWhite),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          'Overview',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              color: AppColors.background,
              child: Image.asset(
                'assets/icons/fav.png',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
            drawer: _buildDrawer(context),
            body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Information Section
            Container(
              color: const Color(0xFF2C2C2C),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final accountNumber = controller.user.value?.accountNumber ?? '';
                            return Text(
                              accountNumber.isNotEmpty
                                  ? '$accountNumber - ACTIVE'
                                  : 'Loading...',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Obx(() {
                            final customerName = controller.user.value?.customerName ?? '';
                            return Text(
                              customerName.isNotEmpty ? customerName : 'Loading...',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 14,
                              ),
                            );
                          }),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final balance = controller.user.value?.totalBalance ?? 0;
                            return Text(
                              _isBalanceVisible
                                  ? Helpers.formatCurrency(balance)
                                  : '₦ ******',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          const Text(
                            'Ledger Balance: Hidden',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: _isBalanceVisible,
                            onChanged: (value) {
                              setState(() {
                                _isBalanceVisible = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textWhite),
                            onPressed: () => Get.back<void>(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Statement Options Section
            Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Select Range'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Email Statement'),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions List
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.transactions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: controller.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  final isCredit = transaction.isCredit;
                  final barColor = isCredit ? AppColors.success : AppColors.error;
                  final amountColor = isCredit ? AppColors.success : AppColors.error;
                  final amountPrefix = isCredit ? '+' : '-';
                  final dateFormat = DateFormat('dd-MM-yyyy');

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.border.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormat.format(transaction.transactionDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  transaction.receiverName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$amountPrefix ₦ ${Helpers.formatCurrency(transaction.amount, showSymbol: false)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: amountColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'F. I. LAB',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Overview',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                      Get.offAllNamed(AppRoutes.dashboard);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.swap_horiz_outlined,
                    title: 'Transfer',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.transfer);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.phone_outlined,
                    title: 'Airtime Recharge',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.airtime);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.phone_android_outlined,
                    title: 'Data Bundles',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Bills Payment',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.bills);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.qr_code_scanner_outlined,
                    title: 'QR Payments',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Connect to eNaira Wallet',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.schedule_outlined,
                    title: 'Scheduled Payments',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Cards',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.description_outlined,
                    title: 'Cheques',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.flight_takeoff_outlined,
                    title: 'Travel and Leisure',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Bank Services',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Account Officer',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.mail_outline,
                    title: 'Messages',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.location_on_outlined,
                    title: 'Zenith Near Me',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border),
            _buildDrawerItem(
              icon: Icons.power_settings_new,
              title: 'Sign Out',
              textColor: AppColors.primary,
              iconColor: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
    Color? iconColor,
  }) {
    final defaultTextColor = isSelected ? AppColors.primary : AppColors.textPrimary;
    final defaultIconColor = isSelected ? AppColors.primary : AppColors.textSecondary;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? defaultIconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? defaultTextColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
