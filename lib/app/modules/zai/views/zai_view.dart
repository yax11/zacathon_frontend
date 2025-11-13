import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zai_controller.dart';
import 'package:zenith_ai/widgets/inputs/collapsible_text_input.dart';
import 'package:zenith_ai/widgets/modals/pin_verification_bottom_sheet.dart';
import '../../overview/controllers/overview_controller.dart';
import '../../../data/services/tts/google_tts_service.dart';
import '../../../core/utils/text_helpers.dart';

class ZaiView extends StatefulWidget {
  const ZaiView({super.key});

  @override
  State<ZaiView> createState() => _ZaiViewState();
}

class _ZaiViewState extends State<ZaiView> with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late ZaiController controller;
  late AnimationController _lottieController;
  late GoogleTtsService _ttsService;
  late Worker _chatMessagesWorker;
  late ScrollController _scrollController;
  bool _lottieInitialized = false;
  String?
      _lastShownTransactionId; // Track last shown transaction ID to prevent duplicate modals
  String? _lastSpokenMessageKey;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    // Get the controller - it should be initialized by dashboard binding
    // Use try-catch to handle any edge cases
    try {
      controller = Get.find<ZaiController>();
    } catch (e) {
      // Fallback: create controller if it doesn't exist
      controller = Get.put(ZaiController(), permanent: false);
    }

    try {
      _ttsService = Get.find<GoogleTtsService>();
    } catch (e) {
      _ttsService = Get.put(GoogleTtsService(), permanent: true);
    }

    _chatMessagesWorker = ever<List<Map<String, dynamic>>>(
      controller.chatMessages,
      (messages) {
        if (messages.isEmpty) return;
        final lastMessage = messages.last;
        final text = (lastMessage['text'] as String?)?.trim() ?? '';
        final isUser = lastMessage['isUser'] == true;
        final timestamp = lastMessage['timestamp'];
        final messageKey = timestamp is DateTime
            ? '${text}_${timestamp.millisecondsSinceEpoch}_${isUser ? 1 : 0}'
            : '${text}_${isUser ? 1 : 0}';

        if (text.isNotEmpty && !isUser) {
          if (_lastSpokenMessageKey != messageKey) {
            _lastSpokenMessageKey = messageKey;
            _ttsService.speak(text);
          }
        }

        _scrollToBottom();
      },
    );

    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _chatMessagesWorker.dispose();
    _lottieController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (controller.isListening.value) {
      await controller.stopListening();
    } else {
      _ttsService.stop();
      await controller.startListening();
    }
  }

  Future<void> _stopAudioAndListening() async {
    if (controller.isListening.value) {
      await controller.stopListening();
    }
    if (_ttsService.isSpeaking.value) {
      await _ttsService.stop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('zen AI'),
        actions: [
          Obx(() {
            final isListening = controller.isListening.value;
            final isProcessing = controller.isProcessing.value;
            final isSpeaking = _ttsService.isSpeaking.value;

            IconData icon;
            String tooltip;
            VoidCallback onPressed;

            if (isListening) {
              icon = Icons.mic_off;
              tooltip = 'Stop listening';
              onPressed = () => controller.stopListening();
            } else if (isSpeaking) {
              icon = Icons.pause_circle_filled;
              tooltip = 'Stop audio';
              onPressed = () => _ttsService.stop();
            } else if (isProcessing) {
              icon = Icons.pause_circle_outline;
              tooltip = 'Cancel processing';
              onPressed = _stopAudioAndListening;
            } else {
              icon = Icons.play_circle_fill;
              tooltip = 'Start listening';
              onPressed = _toggleListening;
            }

            return Row(
              children: [
                if (isListening)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      'Listening...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(icon, color: Colors.white),
                  tooltip: tooltip,
                  onPressed: onPressed,
                ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() {
              if (controller.chatMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        size: 80,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Zenith AI Assistant',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask me anything about your banking',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Tap the mic button or type a message below',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Check if last message needs PIN verification
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
                    message: lastMessage['text'] as String? ??
                        'Please verify your PIN to complete the transaction.',
                  );
                });
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = controller.chatMessages[index];
                  return _buildMessageBubble(context, message);
                },
              );
            }),
          ),

          // Processing indicator
          Obx(() => controller.isProcessing.value
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AI is thinking...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),

          // Text input and animation row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final showCompactLayout = availableWidth < 380;

                Widget controls = GestureDetector(
                  onTap: _toggleListening,
                  child: SizedBox(
                    width: showCompactLayout ? 64 : 80,
                    height: showCompactLayout ? 64 : 80,
                    child: Lottie.asset(
                      'assets/animations/zenAI.json',
                      controller: _lottieController,
                      repeat: true,
                      onLoaded: (composition) {
                        if (_lottieInitialized) return;
                        _lottieInitialized = true;
                        _lottieController
                          ..duration = composition.duration
                          ..repeat();
                      },
                    ),
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CollapsibleTextInput(
                            controller: _textController,
                            onSend: (text) {
                              controller.sendTextMessage(text);
                              _textController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        controls,
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final rawText = message['text'] as String;
    final text = isUser ? rawText : TextHelpers.stripSsmlForDisplay(rawText);
    final transactionId = message['transactionId'];
    final hasTransactionId =
        transactionId != null && transactionId.toString().isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: hasTransactionId && !isUser
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
              : Border.all(color: AppColors.border.withOpacity(0.2)),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            if (hasTransactionId && !isUser) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PIN verification required',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (!isUser) ...[
              const SizedBox(height: 8),
              Obx(() {
                final isSpeaking = _ttsService.isSpeaking.value &&
                    _ttsService.currentText.value == rawText;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isSpeaking) ...[
                      SizedBox(
                        width: 60,
                        height: 28,
                        child: Lottie.asset(
                          'assets/animations/wave-voice.json',
                          repeat: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _ttsService.stop,
                        icon: const Icon(Icons.stop, size: 16),
                        label: const Text('Stop'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ] else
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () => _ttsService.speak(rawText),
                        tooltip: 'Play response',
                      ),
                  ],
                );
              }),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTime(message['timestamp'] as DateTime),
              style: TextStyle(
                color: isUser ? Colors.white70 : AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
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
          'text': result['message'] as String? ??
              'Transaction completed successfully',
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
