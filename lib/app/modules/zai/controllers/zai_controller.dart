import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/api/api_client.dart' show ApiClient, ApiException;
import '../../../data/services/api/api_endpoints.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZaiController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiClient _apiClient = ApiClient();
  final AuthRepository _authRepository = AuthRepository();
  
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

    // Process voice command
    processVoiceMessage(command);
  }

  void sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    chatMessages.add({
      'text': text,
      'isUser': true,
      'timestamp': DateTime.now(),
    });

    processVoiceMessage(text);
  }

  Future<void> processVoiceMessage(String userMessage) async {
    isProcessing.value = true;

    try {
      // Get user's phone number
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        chatMessages.add({
          'text': 'User not found. Please login again.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        isProcessing.value = false;
        return;
      }

      // Get base URL for logging
      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      final apiBaseUrl = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.voiceAssistant}';

      // Log API request
      print('=== Voice Assistant Request ===');
      print('Method: POST');
      print('Full URL: $fullUrl');
      print('Request Data: {phoneNumber: ${user.phoneNumber}, message: $userMessage}');
      print('===============================');

      final response = await _apiClient.post(
        ApiEndpoints.voiceAssistant,
        data: {
          'phoneNumber': user.phoneNumber,
          'message': userMessage,
        },
      );

      // Log API response
      print('=== Voice Assistant Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('================================');

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;
        final responseText = data['response'] ?? '';
        final transactionId = data['transactionId'];
        final action = data['action'];

        if (success) {
          // Store response data for PIN verification if needed
          final responseData = {
            'text': responseText,
            'isUser': false,
            'timestamp': DateTime.now(),
            'transactionId': transactionId,
            'action': action,
            'data': data['data'],
          };

          chatMessages.add(responseData);

          // If transactionId exists, trigger PIN verification callback
          if (transactionId != null && transactionId.toString().isNotEmpty) {
            // Notify listeners that PIN verification is needed
            // The view will handle showing the PIN modal
            Get.rawSnackbar(
              message: 'PIN verification required',
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          chatMessages.add({
            'text': responseText.isNotEmpty ? responseText : 'An error occurred. Please try again.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        }
      }
    } on ApiException catch (e) {
      print('=== Voice Assistant Exception ===');
      print('Message: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('=================================');
      chatMessages.add({
        'text': e.message,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      print('=== Voice Assistant Error ===');
      print('Error: ${e.toString()}');
      print('==============================');
      chatMessages.add({
        'text': 'An error occurred: ${e.toString()}',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    } finally {
      isProcessing.value = false;
    }
  }

  Future<Map<String, dynamic>> verifyTransaction({
    required String transactionId,
    required String pin,
  }) async {
    try {
      // Get user's phone number
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found. Please login again.',
        };
      }

      // Get base URL for logging
      String baseUrl;
      try {
        baseUrl = dotenv.env['BASE_URL'] ?? AppConstants.baseUrl;
      } catch (e) {
        baseUrl = AppConstants.baseUrl;
      }
      final apiBaseUrl = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
      final fullUrl = '$apiBaseUrl${ApiEndpoints.verifyTransaction}';

      // Log API request
      print('=== Verify Transaction Request (from ZAI) ===');
      print('Method: POST');
      print('Full URL: $fullUrl');
      print('Request Data: {phoneNumber: ${user.phoneNumber}, transactionId: $transactionId, pin: ***}');
      print('==============================================');

      final response = await _apiClient.post(
        ApiEndpoints.verifyTransaction,
        data: {
          'phoneNumber': user.phoneNumber,
          'transactionId': transactionId,
          'pin': pin,
        },
      );

      // Log API response
      print('=== Verify Transaction Response (from ZAI) ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('===============================================');

      if (response.statusCode == 200) {
        final data = response.data;
        final success = data['success'] ?? false;

        if (success) {
          return {
            'success': true,
            'message': data['response'] ?? data['message'] ?? 'Transaction verified successfully',
          };
        }
      }

      // Handle 404 or other errors
      final errorMessage = response.data['message'] ??
          response.data['error'] ??
          'Transaction verification failed';

      return {
        'success': false,
        'message': errorMessage,
        'isExpired': response.statusCode == 404 ||
            errorMessage.toLowerCase().contains('expired'),
      };
    } on ApiException catch (e) {
      print('=== Verify Transaction Exception (from ZAI) ===');
      print('Message: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('==============================================');
      return {
        'success': false,
        'message': e.message,
        'isExpired': e.statusCode == 404 ||
            e.message.toLowerCase().contains('expired'),
      };
    } catch (e) {
      print('=== Verify Transaction Error (from ZAI) ===');
      print('Error: ${e.toString()}');
      print('============================================');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  void clearChat() {
    chatMessages.clear();
  }
}

