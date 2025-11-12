import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final rememberLogin = false.obs;

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
                  controller: emailController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '1217822311',
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cannot be empty';
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
                      obscureText: !controller.isPasswordVisible.value,
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
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Cannot be empty';
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
                  final isDisabled = controller.isLoading.value;
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
                                    controller.login(
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                    );
                                  }
                                },
                          isLoading: controller.isLoading.value,
                          isFullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => controller.isBiometricAvailable.value
                          ? SizedBox(
                              width: 56,
                              height: 56,
                              child: InkWell(
                                onTap: controller.loginWithBiometrics,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
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
