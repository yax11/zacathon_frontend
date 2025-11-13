import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../core/constants/app_routes.dart';
import '../../zai/controllers/zai_controller.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;
  final recognizedText = ''.obs;
  final isListening = false.obs;
  final soundLevel = 0.0.obs;
  final aiResponse = ''.obs;
  final isProcessing = false.obs;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Overview',
      'route': AppRoutes.overview,
      'hugeIcon': HugeIconsStrokeRounded.strokeRoundedMenu01,
    },
    {
      'title': 'Airtime',
      'route': AppRoutes.airtime,
      'hugeIcon': HugeIconsStrokeRounded.strokeRoundedSignalFull02,
    },
    {
      'title': 'zen AI',
      'route': AppRoutes.zai,
      'iconData': Icons.smart_toy_outlined,
    },
    {
      'title': 'Transfer',
      'route': AppRoutes.transfer,
      'hugeIcon': HugeIconsStrokeRounded.strokeRoundedArrowDataTransferHorizontal,
    },
    {
      'title': 'Bills',
      'route': AppRoutes.bills,
      'hugeIcon': HugeIconsStrokeRounded.strokeRoundedWallet02,
    },
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = 0; // Start with Overview
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
      },
    );
  }

  Future<void> prepareAIModal() async {
    await stopListening();
    recognizedText.value = '';
    aiResponse.value = '';
    soundLevel.value = 0;
    isListening.value = false;
    isProcessing.value = false;
  }

  Future<void> startListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      recognizedText.value = 'Microphone permission denied';
      return;
    }

    if (!_speechAvailable) {
      await _initializeSpeech();
      if (!_speechAvailable) {
        recognizedText.value = 'Speech recognition unavailable';
        return;
      }
    }

    recognizedText.value = '';
    aiResponse.value = '';
    isListening.value = true;
    soundLevel.value = 0;
    await _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          stopListening();
          // Process the recognized text with voice assistant
          _processVoiceCommand(result.recognizedWords);
        }
      },
      onSoundLevelChange: (level) {
        soundLevel.value = level;
      },
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _processVoiceCommand(String command) async {
    if (command.trim().isEmpty) return;

    try {
      isProcessing.value = true;
      aiResponse.value = '';

      // Get ZaiController
      ZaiController zaiController;
      try {
        zaiController = Get.find<ZaiController>();
      } catch (e) {
        zaiController = Get.put(ZaiController(), permanent: false);
      }

      // Add user message to chat
      zaiController.chatMessages.add({
        'text': command,
        'isUser': true,
        'timestamp': DateTime.now(),
      });

      // Call the voice assistant API
      await zaiController.processVoiceMessage(command);

      // Wait for processing to complete
      while (zaiController.isProcessing.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Get the last message from ZaiController to extract response
      if (zaiController.chatMessages.isNotEmpty) {
        final lastMessage = zaiController.chatMessages.last;
        if (!lastMessage['isUser']) {
          final responseText = lastMessage['text'] as String? ?? '';

          aiResponse.value = responseText;

          // If transactionId exists, we'll handle PIN verification in the modal
          // For now, just show the response
        }
      }
    } catch (e) {
      aiResponse.value = 'Error: ${e.toString()}';
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> stopListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
    }
    soundLevel.value = 0;
  }

  Future<void> resetSpeech() async {
    await prepareAIModal();
  }

  @override
  void onClose() {
    _speech.stop();
    super.onClose();
  }
}
