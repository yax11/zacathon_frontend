import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class BillsView extends StatefulWidget {
  const BillsView({super.key});

  @override
  State<BillsView> createState() => _BillsViewState();
}

class _BillsViewState extends State<BillsView> {
  String? _selectedBillerCollection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textWhite),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          'Bill Payment',
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
            child: Image.asset(
              'assets/icons/fav.png',
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bills Payment History Button
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bills Payment History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Biller Collection
            const Text(
              'Select Biller Collection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBillerCard(
                    icon: Icons.description_outlined,
                    label: 'Zenith Billers',
                    isSelected: _selectedBillerCollection == 'zenith',
                    onTap: () => setState(() => _selectedBillerCollection = 'zenith'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBillerCard(
                    icon: Icons.flash_on_outlined,
                    label: 'Quickteller Merchants',
                    isSelected: _selectedBillerCollection == 'quickteller',
                    onTap: () => setState(() => _selectedBillerCollection = 'quickteller'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Select an Account
            _buildDropdownField(
              label: 'Select an Account',
              hint: 'Select Account',
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Select Category
            _buildDropdownField(
              label: 'Select Category',
              hint: 'Select Category',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillerCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textWhite,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
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
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
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
            const Divider(color: AppColors.border),
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
