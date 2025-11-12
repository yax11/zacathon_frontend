import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../widgets/success_modal.dart';

class AirtimeView extends StatefulWidget {
  const AirtimeView({super.key});

  @override
  State<AirtimeView> createState() => _AirtimeViewState();
}

class _AirtimeViewState extends State<AirtimeView> {
  String? _selectedAccount;
  String? _selectedOperator;
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _scheduleAirtime = false;

  final List<Map<String, dynamic>> _accounts = [
    {
      'name': 'FINNSTART INNOVATION LAB',
      'accountNumber': '1217822311',
      'balance': '₦ *****',
      'currency': 'NGN',
    },
    {
      'name': 'TITUS TUKURAH YAKUBU',
      'accountNumber': '2252925762',
      'balance': '₦ *****',
      'currency': 'NGN',
    },
  ];

  final List<Map<String, dynamic>> _operators = [
    {'name': 'MTN', 'color': const Color(0xFFFFD700)},
    {'name': 'glo', 'color': const Color(0xFF008000)},
    {'name': 'airtel', 'color': const Color(0xFFE60000)},
    {'name': '9Mobi', 'color': Colors.black},
  ];

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAccountSelectionModal(BuildContext context) {
    String? selectedAccount;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select an Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        final accountLabel =
                            '${account['name']} - ${account['accountNumber']}';

                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedAccount = accountLabel;
                            });
                            setState(() {
                              _selectedAccount = accountLabel;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.border.withOpacity(0.5),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        accountLabel,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        account['balance'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<String>(
                                  value: accountLabel,
                                  groupValue: selectedAccount,
                                  onChanged: (value) {
                                    setModalState(() {
                                      selectedAccount = value;
                                    });
                                    setState(() {
                                      _selectedAccount = accountLabel;
                                    });
                                    Navigator.pop(context);
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleContinue() {
    // Show success modal
    SuccessModal.show(
      context: context,
      title: 'Success',
      message: 'Your airtime recharge to ${_mobileNumberController.text} was successful',
      onViewReceipt: () {
        Navigator.pop(context);
        Get.toNamed(AppRoutes.receipt, arguments: {
          'type': 'Airtime Recharge',
          'date': DateTime.now(),
          'account': _selectedAccount ?? '',
          'mobileNumber': _mobileNumberController.text,
          'operator': _selectedOperator ?? '',
          'amount': _amountController.text,
          'status': 'Success',
        });
      },
      onSavePayment: () {
        Navigator.pop(context);
        // TODO: Implement save payment
      },
      onClose: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textWhite),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: const Text(
            'Airtime Recharge',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Select an Account
              _buildDropdownField(
                label: 'Select an Account',
                hint: _selectedAccount ?? 'Select Account',
                onTap: () => _showAccountSelectionModal(context),
              ),
              const SizedBox(height: 24),

              // Select Mobile Operator
              const Text(
                'Select Mobile Operator',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _operators.map((operator) {
                  final isSelected = _selectedOperator == operator['name'];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: operator == _operators.last ? 0 : 8,
                      ),
                      child: _buildOperatorCard(
                        name: operator['name'] as String,
                        color: operator['color'] as Color,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedOperator = operator['name'] as String),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Mobile Number
              _buildTextField(
                label: 'Mobile Number',
                hint: 'Mobile Number',
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Not in my beneficiaries?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement select from contacts
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Select from contacts',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount
              _buildTextField(
                label: 'Amount',
                hint: '0.00',
                controller: _amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Schedule Airtime
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedule Airtime',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Switch(
                    value: _scheduleAirtime,
                    onChanged: (value) =>
                        setState(() => _scheduleAirtime = value),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Continue and Fingerprint buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textSecondary,
                          foregroundColor: AppColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
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
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.fingerprint,
                        color: AppColors.textWhite,
                      ),
                      onPressed: () {
                        // TODO: Implement biometric authentication
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              borderRadius: BorderRadius.zero,
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
    TextEditingController? controller,
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
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorCard({
    required String name,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (name == 'MTN')
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'MTN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (name == 'glo')
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'glo',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (name == 'airtel')
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'a',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
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
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
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
