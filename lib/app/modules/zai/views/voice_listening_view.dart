import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zai_controller.dart';
import 'package:zenith_ai/widgets/modals/pin_verification_bottom_sheet.dart';
import '../../overview/controllers/overview_controller.dart';

class VoiceListeningView extends StatefulWidget {
  const VoiceListeningView({super.key});

  @override
  State<VoiceListeningView> createState() => _VoiceListeningViewState();
}

class _VoiceListeningViewState extends State<VoiceListeningView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late List<Animation<double>> _rippleAnimations;

  late ZaiController controller;
  String? _lastShownTransactionId; // Track last shown transaction ID to prevent duplicate modals

  @override
  void initState() {
    super.initState();
    
    // Get the controller - it should exist from dashboard binding
    try {
      controller = Get.find<ZaiController>();
    } catch (e) {
      // Fallback: create controller if it doesn't exist
      controller = Get.put(ZaiController(), permanent: false);
    }

    // Pulse animation for the center circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ripple animations for expanding circles
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rippleAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _rippleController,
          curve: Interval(
            index * 0.3,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    // Start listening when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startListening();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Obx(() => Stack(
          children: [
            // Animated circles background
            ...List.generate(3, (index) {
              return Positioned.fill(
                child: AnimatedBuilder(
                  animation: _rippleAnimations[index],
                  builder: (context, child) {
                    final animationValue = _rippleAnimations[index].value;
                    final opacity = (1 - animationValue).clamp(0.0, 0.3);
                    final scale = 1.0 + (animationValue * 2.0);

                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(opacity),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          controller.stopListening();
                          Get.back();
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          controller.stopListening();
                          Get.back();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Voice indicator
                Obx(() {
                  if (controller.isRecording.value) {
                    return Column(
                      children: [
                        // Animated microphone icon
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                                child: const Icon(
                                  Icons.mic,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Listening...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          // Check if last message needs PIN verification
                          if (controller.chatMessages.isNotEmpty) {
                            final lastMessage = controller.chatMessages.last;
                            final transactionId = lastMessage['transactionId'];
                            if (transactionId != null && 
                                transactionId.toString().isNotEmpty && 
                                !lastMessage['isUser'] &&
                                _lastShownTransactionId != transactionId.toString()) {
                              // Mark this transaction ID as shown
                              _lastShownTransactionId = transactionId.toString();
                              // Show PIN verification modal after a short delay
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showPinVerificationModal(
                                  context: context,
                                  transactionId: transactionId.toString(),
                                  message: lastMessage['text'] as String? ?? 'Please verify your PIN to complete the transaction.',
                                );
                              });
                            }
                          }

                          return Text(
                            controller.recognizedText.value.isEmpty
                                ? 'Say something'
                                : controller.recognizedText.value,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.mic_none,
                            size: 60,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Tap to start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }
                }),

                const Spacer(),

                // Action button
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Obx(() {
                    if (controller.isRecording.value) {
                      return FloatingActionButton.extended(
                        onPressed: () => controller.stopListening(),
                        backgroundColor: AppColors.primary,
                        icon: const Icon(Icons.stop, color: Colors.white),
                        label: const Text(
                          'Stop',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return FloatingActionButton.extended(
                        onPressed: () => controller.startListening(),
                        backgroundColor: AppColors.primary,
                        icon: const Icon(Icons.mic, color: Colors.white),
                        label: const Text(
                          'Start Listening',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ],
        )),
      ),
    );
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
          return await controller.verifyTransaction(
            transactionId: txnId,
            pin: pin,
          );
        },
      ),
    ).then((result) {
      if (result != null && result['success'] == true) {
        // Add success message to chat
        controller.chatMessages.add({
          'text': result['message'] as String? ?? 'Transaction completed successfully',
          'isUser': false,
          'timestamp': DateTime.now(),
        });

        // Refresh overview and dashboard data
        try {
          if (Get.isRegistered<OverviewController>()) {
            final overviewController = Get.find<OverviewController>();
            overviewController.refreshData();
          }
        } catch (e) {
          print('Error refreshing overview: $e');
        }

        Get.snackbar(
          'Success',
          result['message'] as String? ?? 'Transaction completed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );

        // Close voice listening view and go back
        Get.back();
      } else if (result != null && result['success'] == false) {
        final errorMessage = result['message'] as String;
        final isExpired = result['isExpired'] == true;

        // Add error message to chat
        controller.chatMessages.add({
          'text': errorMessage,
          'isUser': false,
          'timestamp': DateTime.now(),
        });

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

