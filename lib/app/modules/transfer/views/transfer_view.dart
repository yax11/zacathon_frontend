import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'account_ocr_view.dart';
import '../../airtime/widgets/success_modal.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  int _selectedTab = 0;
  String? _selectedTransferMode;
  bool _scheduleTransfer = false;
  String? _selectedSourceAccount;
  String? _selectedDestinationAccount;
  String? _selectedBank;
  bool _saveAsBeneficiary = false;

  final TextEditingController _destinationAccountController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
    {
      'name': 'FINNSTART INNOVATION LAB',
      'accountNumber': '5075479818',
      'balance': '\$*****',
      'currency': 'USD',
    },
    {
      'name': 'FINNSTART INNOVATION LAB',
      'accountNumber': '5081390327',
      'balance': '€*****',
      'currency': 'EUR',
    },
    {
      'name': 'TITUS TUKURAH YAKUBU',
      'accountNumber': '5071032653',
      'balance': '\$*****',
      'currency': 'USD',
    },
  ];

  final List<String> _banks = [
    'Access Bank',
    'First Bank',
    'Guarantee Trust Bank',
    'Zenith Bank',
    'United Bank for Africa',
    'Stanbic IBTC',
    'Union Bank',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTransferMode ??= 'zenith';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get transfer mode from route arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['transferMode'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedTransferMode = args['transferMode'] as String;
        });
      });
    }
  }

  @override
  void dispose() {
    _destinationAccountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _changeTransferMode(String mode) {
    setState(() {
      _selectedTransferMode = mode;
      _destinationAccountController.clear();
      _selectedDestinationAccount = null;
      if (mode != 'other' && mode != 'foreign') {
        _selectedBank = null;
      }
    });
  }

  void _handleContinue() {
    final beneficiaryName =
        _selectedDestinationAccount ?? _destinationAccountController.text;
    final bankInfo = _selectedBank != null
        ? '(${_selectedBank}: ${_destinationAccountController.text})'
        : '';
    // Show success modal
    SuccessModal.show(
      context: context,
      title: 'Success',
      message: 'Your transfer to $beneficiaryName$bankInfo was successful',
      onViewReceipt: () {
        Navigator.pop(context);
        Get.toNamed(AppRoutes.receipt, arguments: {
          'type': 'Inter-Bank Transfer',
          'date': DateTime.now(),
          'account': _selectedSourceAccount ?? '',
          'creditAccount': _destinationAccountController.text,
          'beneficiary': _destinationAccountController.text,
          'bank': _selectedBank ?? 'Zenith Bank',
          'narration': _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Done',
          'status': 'Success',
          'amount': 'N${_amountController.text}',
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
    final currentMode = _selectedTransferMode ?? 'zenith';
    final isOwn = currentMode == 'own';
    final isOther = currentMode == 'other';
    final isForeign = currentMode == 'foreign';
    final showBankField = isOther || isForeign;

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
                      onTap: () => _changeTransferMode('zenith'),
                    ),
                    const SizedBox(width: 12),
                    _buildTransferModeCard(
                      icon: Icons.account_balance_outlined,
                      label: 'Other Banks',
                      isSelected: _selectedTransferMode == 'other',
                      onTap: () => _changeTransferMode('other'),
                    ),
                    const SizedBox(width: 12),
                    _buildTransferModeCard(
                      icon: Icons.language_outlined,
                      label: 'Foreign Transfer',
                      isSelected: _selectedTransferMode == 'foreign',
                      onTap: () => _changeTransferMode('foreign'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              _buildDropdownField(
                label: 'Select Source Account',
                hint: _selectedSourceAccount ?? 'Select Account',
                onTap: () => _showAccountSelectionModal(context, true),
              ),
              const SizedBox(height: 16),
              if (showBankField) ...[
                _buildDropdownField(
                  label: 'Select a Bank',
                  hint: _selectedBank ?? 'Select Bank',
                  onTap: () => _showBankSelectionModal(context),
                ),
                const SizedBox(height: 16),
              ],
              if (isOwn) ...[
                _buildDropdownField(
                  label: 'Select Destination Account',
                  hint: _selectedDestinationAccount ?? 'Select Account',
                  onTap: () => _showAccountSelectionModal(context, false),
                ),
              ] else ...[
                _buildAccountNumberField(),
              ],
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Amount',
                hint: '0.00',
                keyboardType: TextInputType.number,
                controller: _amountController,
              ),

              const SizedBox(height: 16),
              _buildTextField(
                label: 'Transaction Description',
                hint: 'Transaction Description',
                controller: _descriptionController,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Save as Beneficiary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Switch(
                    value: _saveAsBeneficiary,
                    onChanged: (value) =>
                        setState(() => _saveAsBeneficiary = value),
                    activeColor: AppColors.primary,
                  ),
                ],
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
            ],
          ),
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
          borderRadius: BorderRadius.zero,
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
    TextInputType? keyboardType,
    TextEditingController? controller,
    Widget? suffix,
    bool readOnly = false,
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
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            suffixIcon: suffix,
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

  Widget _buildAccountNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Destination Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _destinationAccountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Account Number',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.primary,
              ),
              onPressed: _scanAccountNumber,
            ),
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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Implement beneficiary selection
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Choose Beneficiary',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
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

  void _showAccountSelectionModal(BuildContext context, bool isSource) {
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSource
                              ? 'Select Source Account'
                              : 'Select Destination Account',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Account List
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
                              if (isSource) {
                                _selectedSourceAccount = accountLabel;
                              } else {
                                _selectedDestinationAccount = accountLabel;
                              }
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      if (isSource) {
                                        _selectedSourceAccount = accountLabel;
                                      } else {
                                        _selectedDestinationAccount =
                                            accountLabel;
                                      }
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

  void _showBankSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Bank',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _banks.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final bank = _banks[index];
                    final isSelected = bank == _selectedBank;
                    return ListTile(
                      title: Text(
                        bank,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedBank = bank;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanAccountNumber() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Required',
        'Camera access is needed to scan account numbers.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to<String>(() => const AccountOcrView());
    if (result != null && result.isNotEmpty) {
      setState(() {
        _destinationAccountController.text = result;
      });
      Get.snackbar(
        'Account Detected',
        'Account number has been filled automatically.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (result != null) {
      Get.snackbar(
        'Not Found',
        'Could not detect a valid account number. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
