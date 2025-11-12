import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ZaiController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  final isListening = false.obs;
  final isRecording = false.obs;
  final recognizedText = ''.obs;
  final chatMessages = <Map<String, dynamic>>[].obs;
  final textController = ''.obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isRecording.value = false;
        }
      },
      onError: (error) {
        Get.snackbar('Error', 'Speech recognition error: $error.errorMsg');
        isRecording.value = false;
        isListening.value = false;
      },
    );
    
    if (!available) {
      Get.snackbar('Error', 'Speech recognition not available');
    }
  }

  Future<void> startListening() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Microphone permission is required');
      return;
    }

    if (!await _speech.initialize()) {
      Get.snackbar('Error', 'Speech recognition not available');
      return;
    }

    isListening.value = true;
    isRecording.value = true;
    recognizedText.value = '';

    await _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          isRecording.value = false;
          isListening.value = false;
          _processVoiceCommand(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isRecording.value = false;
    isListening.value = false;
    
    if (recognizedText.value.isNotEmpty) {
      _processVoiceCommand(recognizedText.value);
    }
  }

  void _processVoiceCommand(String command) {
    if (command.isEmpty) return;

    // Add user message
    chatMessages.add({
      'text': command,
      'isUser': true,
      'timestamp': DateTime.now(),
    });

    // Simulate AI response
    _simulateAIResponse(command);
  }

  void sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    chatMessages.add({
      'text': text,
      'isUser': true,
      'timestamp': DateTime.now(),
    });

    _simulateAIResponse(text);
  }

  void _simulateAIResponse(String userMessage) {
    isProcessing.value = true;

    // Simulate API delay
    Future.delayed(const Duration(seconds: 1), () {
      String response = _generateMockResponse(userMessage);
      chatMessages.add({
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
      isProcessing.value = false;
    });
  }

  String _generateMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('balance') || message.contains('account')) {
      return 'Your account balance is ₦*****. To view your full balance, please enable "Show balance" in your account settings.';
    } else if (message.contains('transfer') || message.contains('send money')) {
      return 'I can help you transfer money. Please navigate to the Transfer section or tell me the amount and recipient details.';
    } else if (message.contains('bills') || message.contains('pay')) {
      return 'I can assist you with bill payments. Please navigate to the Bills section or tell me which bill you want to pay.';
    } else if (message.contains('airtime') || message.contains('data')) {
      return 'I can help you purchase airtime or data. Please navigate to the Airtime section or tell me the amount you need.';
    } else if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! I\'m your Zenith AI assistant. How can I help you with your banking needs today?';
    } else if (message.contains('help')) {
      return 'I can help you with:\n• Check account balance\n• Transfer money\n• Pay bills\n• Purchase airtime/data\n• Answer banking questions\n\nWhat would you like to do?';
    } else {
      return 'I understand you said: "$userMessage". I\'m here to help with your banking needs. You can ask me about your balance, transfers, bills, or airtime.';
    }
  }

  void clearChat() {
    chatMessages.clear();
  }
}

