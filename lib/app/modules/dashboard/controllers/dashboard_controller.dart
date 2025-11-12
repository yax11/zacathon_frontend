import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_routes.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;
  final recognizedText = ''.obs;
  final isListening = false.obs;
  final soundLevel = 0.0.obs;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Overview',
      'route': AppRoutes.overview,
      'iconAsset': 'assets/icons/overview.png',
    },
    {
      'title': 'Airtime',
      'route': AppRoutes.airtime,
      'iconAsset': 'assets/icons/airtime.png',
    },
    {
      'title': 'zen AI',
      'route': AppRoutes.zai,
      'iconData': Icons.smart_toy_outlined,
    },
    {
      'title': 'Transfer',
      'route': AppRoutes.transfer,
      'iconAsset': 'assets/icons/transfer.png',
    },
    {
      'title': 'Bills',
      'route': AppRoutes.bills,
      'iconAsset': 'assets/icons/bill.png',
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
    soundLevel.value = 0;
    isListening.value = false;
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
    isListening.value = true;
    soundLevel.value = 0;
    await _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          stopListening();
        }
      },
      onSoundLevelChange: (level) {
        soundLevel.value = level;
      },
      listenMode: stt.ListenMode.dictation,
    );
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
