import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import 'account_ocr_view.dart';
import '../../airtime/widgets/success_modal.dart';
import '../controllers/transfer_controller.dart';
import '../../overview/controllers/overview_controller.dart';
import 'package:zenith_ai/widgets/buttons/tab_button.dart';
import 'package:zenith_ai/widgets/buttons/transfer_mode_card.dart';
import 'package:zenith_ai/widgets/inputs/dropdown_field.dart';
import 'package:zenith_ai/widgets/inputs/text_field_widget.dart';
import 'package:zenith_ai/widgets/inputs/account_number_field.dart';
import 'package:zenith_ai/widgets/modals/pin_verification_bottom_sheet.dart';
import 'dart:async';

class TransferView extends GetView<TransferController> {
  const TransferView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<TransferController>()) {
      Get.put(TransferController());
    }
    return _TransferViewContent(controller: controller);
  }
}

class _TransferViewContent extends StatefulWidget {
  final TransferController controller;

  const _TransferViewContent({required this.controller});

  @override
  State<_TransferViewContent> createState() => _TransferViewContentState();
}

class _TransferViewContentState extends State<_TransferViewContent> {
  int _selectedTab = 0;
  String? _selectedTransferMode;
  bool _scheduleTransfer = false;
  String? _selectedSourceAccount;
  String? _selectedSourceAccountNumber;
  String? _selectedDestinationAccount;
  String? _selectedBank;
  bool _saveAsBeneficiary = false;
  Timer? _accountVerificationTimer;

  final TextEditingController _destinationAccountController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // All Nigerian Commercial Banks and Mobile Banks
  final List<String> _banks = [
    // Commercial Banks
    'Access Bank',
    'Citibank Nigeria',
    'Ecobank Nigeria',
    'Fidelity Bank',
    'First Bank of Nigeria',
    'First City Monument Bank',
    'Guaranty Trust Bank',
    'Heritage Bank',
    'Keystone Bank',
    'Polaris Bank',
    'Providus Bank',
    'Stanbic IBTC Bank',
    'Standard Chartered Bank',
    'Sterling Bank',
    'Suntrust Bank',
    'Union Bank of Nigeria',
    'United Bank for Africa',
    'Unity Bank',
    'Wema Bank',
    'Zenith Bank',
    // Mobile/Fintech Banks
    'OPay',
    'PalmPay',
    'Kuda Bank',
    'Carbon',
    'FairMoney',
    'VFD Microfinance Bank',
    'ALAT by Wema',
    'Sparkle',
    'Rubies Bank',
    'VBank',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTransferMode ??= 'zenith';

    // Listen to destination account changes for verification
    _destinationAccountController.addListener(_onDestinationAccountChanged);
  }

  void _onDestinationAccountChanged() {
    final accountNumber = _destinationAccountController.text.trim();

    // Clear previous timer
    _accountVerificationTimer?.cancel();

    // If account number is not 10 digits, clear verified account
    if (accountNumber.length != 10) {
      widget.controller.clearVerifiedAccount();
      if (accountNumber.length < 10) {
        setState(() {
          if (_selectedTransferMode == 'other' ||
              _selectedTransferMode == 'foreign') {
            _selectedBank = null;
          }
        });
      }
      return;
    }

    // Verify immediately when 10 digits are entered (for all transfer modes)
    // Cancel any pending verification
    _accountVerificationTimer?.cancel();

    // Verify account immediately
    widget.controller
        .verifyAccount(accountNumber: accountNumber)
        .then((result) {
      if (mounted &&
          _destinationAccountController.text.trim() == accountNumber) {
        if (result['success'] == true) {
          setState(() {
            // Auto-set bank name from verification response
            if (_selectedTransferMode == 'other' ||
                _selectedTransferMode == 'foreign') {
              // The bank will be set from verifiedBankName observable
              // No need to set _selectedBank as it's now read-only when verified
            }
          });
        } else {
          // Clear bank if verification failed
          if (mounted) {
            setState(() {
              if (_selectedTransferMode == 'other' ||
                  _selectedTransferMode == 'foreign') {
                _selectedBank = null;
              }
            });
          }
        }
      }
    }).catchError((error) {
      print('Account verification error: $error');
      if (mounted) {
        widget.controller.clearVerifiedAccount();
        setState(() {
          if (_selectedTransferMode == 'other' ||
              _selectedTransferMode == 'foreign') {
            _selectedBank = null;
          }
        });
      }
    });
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
    _accountVerificationTimer?.cancel();
    _destinationAccountController.removeListener(_onDestinationAccountChanged);
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
      widget.controller.clearVerifiedAccount();
      if (mode != 'other' && mode != 'foreign') {
        _selectedBank = null;
      }
    });
  }

  bool _isFormValid() {
    // Check source account
    if (_selectedSourceAccountNumber == null ||
        _selectedSourceAccountNumber!.isEmpty) {
      return false;
    }

    // Check destination account
    if (_selectedTransferMode == 'own') {
      if (_selectedDestinationAccount == null ||
          _selectedDestinationAccount!.isEmpty) {
        return false;
      }
    } else {
      if (_destinationAccountController.text.trim().isEmpty) {
        return false;
      }
      // For other/foreign banks, check if bank is selected or verified
      if ((_selectedTransferMode == 'other' ||
          _selectedTransferMode == 'foreign')) {
        final verifiedBankName = widget.controller.verifiedBankName.value;
        if (verifiedBankName.isEmpty &&
            (_selectedBank == null || _selectedBank!.isEmpty)) {
          return false;
        }
      }
    }

    // Check amount
    if (_amountController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  Future<void> _handleContinue() async {
    // Validate required fields
    if (_selectedSourceAccountNumber == null ||
        _selectedSourceAccountNumber!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a source account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    if (_destinationAccountController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter destination account number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    if (_amountController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter transfer amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Check if bank is selected or verified for other/foreign transfers
    if (_selectedTransferMode == 'other' ||
        _selectedTransferMode == 'foreign') {
      final verifiedBankName = widget.controller.verifiedBankName.value;
      if (verifiedBankName.isEmpty &&
          (_selectedBank == null || _selectedBank!.isEmpty)) {
        Get.snackbar(
          'Error',
          'Please select a bank',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }
    }

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Call manual transfer API
    final result = await widget.controller.manualTransfer(
      sourceAccountNumber: _selectedSourceAccountNumber!,
      receiverAccountNumber: _destinationAccountController.text.trim(),
      amount: _amountController.text.trim(),
    );

    // Close loading dialog
    Get.back();

    if (result['success'] == true && result['transactionId'] != null) {
      // Show PIN verification modal
      _showPinVerificationModal(
        context: context,
        transactionId: result['transactionId'] as String,
        message: result['message'] as String,
      );
    } else {
      Get.snackbar(
        'Error',
        result['message'] ?? 'Transfer initiation failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
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
                    child: TabButton(
                      label: 'Transfer History',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TabButton(
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
                    TransferModeCard(
                      icon: Icons.account_balance_outlined,
                      label: 'Zenith Bank',
                      isSelected: _selectedTransferMode == 'zenith',
                      onTap: () => _changeTransferMode('zenith'),
                    ),
                    const SizedBox(width: 12),
                    TransferModeCard(
                      icon: Icons.account_balance_outlined,
                      label: 'Other Banks',
                      isSelected: _selectedTransferMode == 'other',
                      onTap: () => _changeTransferMode('other'),
                    ),
                    const SizedBox(width: 12),
                    TransferModeCard(
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
              Obx(() => DropdownField(
                    label: 'Select Source Account',
                    hint: _selectedSourceAccount ??
                        (widget.controller.accounts.isEmpty
                            ? 'Loading accounts...'
                            : 'Select Account'),
                    onTap: widget.controller.accounts.isEmpty
                        ? null
                        : () => _showAccountSelectionModal(context, true),
                  )),
              const SizedBox(height: 16),
              if (showBankField) ...[
                Obx(() {
                  final verifiedBankName =
                      widget.controller.verifiedBankName.value;
                  final hasVerifiedBank = verifiedBankName.isNotEmpty;

                  if (hasVerifiedBank) {
                    // Show verified bank name widget (full width)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Bank Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  verifiedBankName,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Show bank selection dropdown
                    return DropdownField(
                      label: 'Select a Bank',
                      hint: _selectedBank ?? 'Select Bank',
                      onTap: () => _showBankSelectionModal(context),
                    );
                  }
                }),
                const SizedBox(height: 16),
              ],
              if (isOwn) ...[
                DropdownField(
                  label: 'Select Destination Account',
                  hint: _selectedDestinationAccount ?? 'Select Account',
                  onTap: () => _showAccountSelectionModal(context, false),
                ),
              ] else ...[
                Obx(() => AccountNumberField(
                      controller: _destinationAccountController,
                      onScan: _scanAccountNumber,
                      verifiedAccountName:
                          widget.controller.verifiedAccountName.value.isNotEmpty
                              ? widget.controller.verifiedAccountName.value
                              : null,
                    )),
              ],
              Obx(() {
                if (widget.controller.isVerifyingAccount.value) {
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Lottie.asset(
                            'assets/animations/preloader.json',
                            repeat: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox(height: 16);
              }),
              TextFieldWidget(
                label: 'Amount',
                hint: '0.00',
                keyboardType: TextInputType.number,
                controller: _amountController,
                onChanged: (_) =>
                    setState(() {}), // Trigger rebuild for button state
              ),

              const SizedBox(height: 16),
              TextFieldWidget(
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
              Builder(
                builder: (context) {
                  final isFormValid = _isFormValid();
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isFormValid ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormValid
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        foregroundColor: AppColors.textWhite,
                        disabledBackgroundColor: AppColors.textSecondary,
                        disabledForegroundColor:
                            AppColors.textWhite.withOpacity(0.5),
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
                  );
                },
              ),
            ],
          ),
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
            return Obx(() {
              final accounts = widget.controller.accounts;

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
                      child: widget.controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : accounts.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No accounts available',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: accounts.length,
                                  itemBuilder: (context, index) {
                                    final account = accounts[index];
                                    final accountLabel =
                                        '${account.bankName} - ${account.accountNumber}';
                                    final balanceText =
                                        Helpers.formatCurrency(account.balance);

                                    return InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          selectedAccount = accountLabel;
                                        });
                                        setState(() {
                                          if (isSource) {
                                            _selectedSourceAccount =
                                                accountLabel;
                                            _selectedSourceAccountNumber =
                                                account.accountNumber;
                                          } else {
                                            _selectedDestinationAccount =
                                                accountLabel;
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
                                              color: AppColors.border
                                                  .withOpacity(0.5),
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    balanceText,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .textSecondary,
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
                                                    _selectedSourceAccount =
                                                        accountLabel;
                                                    _selectedSourceAccountNumber =
                                                        account.accountNumber;
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
            });
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

  void _showPinVerificationModal({
    required BuildContext context,
    required String transactionId,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) => PinVerificationBottomSheet(
        transactionId: transactionId,
        message: message,
        onVerify: (txnId, pin) async {
          return await widget.controller.verifyTransaction(
            transactionId: txnId,
            pin: pin,
          );
        },
      ),
    ).then((result) {
      if (result != null && result['success'] == true) {
        final beneficiaryName = widget
                .controller.verifiedAccountName.value.isNotEmpty
            ? widget.controller.verifiedAccountName.value
            : _selectedDestinationAccount ?? _destinationAccountController.text;

        // Refresh overview and dashboard data
        try {
          if (Get.isRegistered<OverviewController>()) {
            final overviewController = Get.find<OverviewController>();
            overviewController.refreshData();
          }
        } catch (e) {
          print('Error refreshing overview: $e');
        }

        // Show success modal
        SuccessModal.show(
          context: context,
          title: 'Success',
          message: result['message'] as String,
          onViewReceipt: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.receipt, arguments: {
              'type': 'Inter-Bank Transfer',
              'date': DateTime.now(),
              'account': _selectedSourceAccount ?? '',
              'creditAccount': _destinationAccountController.text,
              'beneficiary': beneficiaryName,
              'bank': widget.controller.verifiedBankName.value.isNotEmpty
                  ? widget.controller.verifiedBankName.value
                  : (_selectedBank ?? 'Zenith Bank'),
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
          onClose: () {
            Navigator.pop(context);
            // Refresh data when modal closes
            if (Get.isRegistered<OverviewController>()) {
              Get.find<OverviewController>().refreshData();
            }
            // Navigate to overview view
            Get.offAllNamed(AppRoutes.dashboard);
          },
        );
      } else if (result != null && result['success'] == false) {
        final errorMessage = result['message'] as String;
        final isExpired = result['isExpired'] == true;

        Get.snackbar(
          isExpired ? 'Transaction Expired' : 'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }
}
