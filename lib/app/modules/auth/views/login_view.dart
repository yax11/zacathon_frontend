import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return _LoginViewContent(controller: controller);
  }
}

class _LoginViewContent extends StatefulWidget {
  final AuthController controller;

  const _LoginViewContent({required this.controller});

  @override
  State<_LoginViewContent> createState() => _LoginViewContentState();
}

class _LoginViewContentState extends State<_LoginViewContent> {
  late final TextEditingController accountNumberController;
  late final TextEditingController passwordController;
  final formKey = GlobalKey<FormState>();
  final rememberLogin = false.obs;
  Worker? _accountNumberWorker;

  @override
  void initState() {
    super.initState();
    accountNumberController = TextEditingController();
    passwordController = TextEditingController();

    // Listen to saved account number changes
    _accountNumberWorker =
        ever(widget.controller.savedAccountNumber, (String accountNumber) {
      if (accountNumber.isNotEmpty) {
        // Only update if field is empty or different
        if (accountNumberController.text != accountNumber) {
          accountNumberController.text = accountNumber;
        }
      }
    });

    // Check if already loaded - use multiple callbacks to ensure we catch it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPrefillAccountNumber();
    });

    // Also check after a short delay in case async loading is still in progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkAndPrefillAccountNumber();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkAndPrefillAccountNumber();
      }
    });
  }

  void _checkAndPrefillAccountNumber() {
    if (widget.controller.savedAccountNumber.value.isNotEmpty &&
        accountNumberController.text.isEmpty) {
      accountNumberController.text = widget.controller.savedAccountNumber.value;
    }
  }

  @override
  void dispose() {
    _accountNumberWorker?.dispose();
    accountNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
          onPressed: () => Get.back<void>(),
        ),
        title: const Text('Welcome'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(0),
              ),
              child: Image.asset(
                'assets/icons/fav.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account Number label + field
                const Text(
                  'Account Number',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  decoration: const InputDecoration(
                    hintText: '08012345678',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 190, 190, 190)),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cannot be empty';
                    }
                    if (value.length != 11) {
                      return 'Account number must be 11 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password label + field
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => TextFormField(
                      controller: passwordController,
                      obscureText: !widget.controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 190, 190, 190)),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            widget.controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: widget.controller.togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Cannot be empty';
                        }
                        if (value != '123456') {
                          return 'Invalid password';
                        }
                        return null;
                      },
                    )),

                const SizedBox(height: 8),

                // Remember login
                Obx(() => Row(
                      children: [
                        Checkbox(
                          value: rememberLogin.value,
                          onChanged: (v) => rememberLogin.value = v ?? false,
                        ),
                        const Text('Remember login'),
                      ],
                    )),

                const SizedBox(height: 12),

                // Sign in + Fingerprint
                Obx(() {
                  final isDisabled = widget.controller.isLoading.value;
                  return Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'SIGN IN',
                          size: ButtonSize.large,
                          onPressed: isDisabled
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    widget.controller.login(
                                      accountNumber:
                                          accountNumberController.text.trim(),
                                      password: passwordController.text,
                                    );
                                  }
                                },
                          isLoading: widget.controller.isLoading.value,
                          isFullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => widget.controller.isBiometricAvailable.value
                          ? SizedBox(
                              width: 56,
                              height: 56,
                              child: InkWell(
                                onTap:
                                    widget.controller.isBiometricLoading.value
                                        ? null
                                        : widget.controller.loginWithBiometrics,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget
                                            .controller.isBiometricLoading.value
                                        ? AppColors.primary.withOpacity(0.6)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: widget
                                          .controller.isBiometricLoading.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.textWhite,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.fingerprint,
                                          color: AppColors.textWhite,
                                          size: 28,
                                        ),
                                ),
                              ),
                            )
                          : const SizedBox(width: 56, height: 56)),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Forgot password
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),

                const SizedBox(height: 8),

                // Continue in Internet Banking
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Continue in Internet Banking',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
