import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  int _selectedTab = 0;
  String? _selectedTransferMode;
  bool _scheduleTransfer = false;

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
          'Transfers',
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
            // Tabs
            Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    label: 'Transfer History',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    label: 'Saved Transfers',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Select Transfer Mode
            const Text(
              'Select Transfer Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 12),
                  _buildTransferModeCard(
                    icon: Icons.account_balance_outlined,
                    label: 'Zenith Bank',
                    isSelected: _selectedTransferMode == 'zenith',
                    onTap: () =>
                        setState(() => _selectedTransferMode = 'zenith'),
                  ),
                  const SizedBox(width: 12),
                  _buildTransferModeCard(
                    icon: Icons.account_balance_outlined,
                    label: 'Other Banks',
                    isSelected: _selectedTransferMode == 'other',
                    onTap: () =>
                        setState(() => _selectedTransferMode = 'other'),
                  ),
                  const SizedBox(width: 12),
                  _buildTransferModeCard(
                    icon: Icons.language_outlined,
                    label: 'Foreign Transfer',
                    isSelected: _selectedTransferMode == 'foreign',
                    onTap: () =>
                        setState(() => _selectedTransferMode = 'foreign'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildDropdownField(
              label: 'Select Source Account',
              hint: 'Select Account',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Select Destination Account',
              hint: 'Select Account',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Amount',
              hint: '0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Transaction Description',
              hint: 'Transaction Description',
            ),
            const SizedBox(height: 16),

            // Schedule Transfer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule Transfer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Switch(
                  value: _scheduleTransfer,
                  onChanged: (value) =>
                      setState(() => _scheduleTransfer = value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textSecondary,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransferModeCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
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
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
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
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
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
    final defaultTextColor =
        isSelected ? AppColors.primary : AppColors.textPrimary;
    final defaultIconColor =
        isSelected ? AppColors.primary : AppColors.textSecondary;

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
