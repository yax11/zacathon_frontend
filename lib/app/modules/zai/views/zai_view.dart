import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zai_controller.dart';
import 'voice_listening_view.dart';
import 'package:zenith_ai/widgets/inputs/collapsible_text_input.dart';

class ZaiView extends StatefulWidget {
  const ZaiView({super.key});

  @override
  State<ZaiView> createState() => _ZaiViewState();
}

class _ZaiViewState extends State<ZaiView> with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late ZaiController controller;
  late AnimationController _lottieController;
  bool _lottieInitialized = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    // Get the controller - it should be initialized by dashboard binding
    // Use try-catch to handle any edge cases
    try {
      controller = Get.find<ZaiController>();
    } catch (e) {
      // Fallback: create controller if it doesn't exist
      controller = Get.put(ZaiController(), permanent: false);
    }
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('zen AI'),
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

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = controller.chatMessages[index];
                  return _buildMessageBubble(message);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CollapsibleTextInput(
                  controller: _textController,
                  onSend: (text) {
                    controller.sendTextMessage(text);
                    _textController.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const VoiceListeningView());
                  },
                  child: SizedBox(
                    width: 80,
                    height: 80,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.backgroundLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
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
}
