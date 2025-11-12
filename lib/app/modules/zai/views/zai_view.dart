import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zai_controller.dart';
import 'voice_listening_view.dart';

class ZaiView extends StatefulWidget {
  const ZaiView({super.key});

  @override
  State<ZaiView> createState() => _ZaiViewState();
}

class _ZaiViewState extends State<ZaiView> {
  late TextEditingController _textController;
  late ZaiController controller;

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
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('zAI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.clearChat(),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice command button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: CustomButton(
              text: 'Voice Command',
              icon: Icons.mic,
              onPressed: () {
                Get.to(() => const VoiceListeningView());
              },
              isFullWidth: true,
            ),
          ),

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

          // Text input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            controller.sendTextMessage(text);
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      final text = value.trim();
                      if (text.isNotEmpty) {
                        controller.sendTextMessage(text);
                        _textController.clear();
                      }
                    },
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
                color: isUser
                    ? Colors.white70
                    : AppColors.textLight,
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
