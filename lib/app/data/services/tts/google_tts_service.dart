import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';

class GoogleTtsService extends GetxService {
  GoogleTtsService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://texttospeech.googleapis.com/v1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<void>? _playerCompleteSub;

  final RxBool isSpeaking = false.obs;
  final RxString lastError = ''.obs;
  final RxString currentText = ''.obs;

  String? _currentText;

  @override
  void onInit() {
    super.onInit();
    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((event) {
      isSpeaking.value = false;
      _currentText = null;
      currentText.value = '';
    });
  }

  Future<void> speak(String text) async {
    final unescape = HtmlUnescape();
    final normalized = unescape.convert(text);
    final trimmed = normalized.trim();
    if (trimmed.isEmpty) {
      return;
    }

    // Try to get GOOGLE_TTS_API_KEY from environment, with error handling
    String apiKey;
    try {
      apiKey = dotenv.env['GOOGLE_TTS_API_KEY'] ?? '';
    } catch (e) {
      // If dotenv is not loaded, set empty string
      apiKey = '';
    }

    if (apiKey.isEmpty) {
      lastError.value = 'Missing GOOGLE_TTS_API_KEY in .env';
      print('GoogleTtsService: GOOGLE_TTS_API_KEY is not set.');
      return;
    }

    try {
      // Avoid replaying the same text while it is already playing
      if (isSpeaking.value && trimmed == _currentText) {
        return;
      }

      await stop();

      isSpeaking.value = true;
      lastError.value = '';
      _currentText = trimmed;
      currentText.value = trimmed;

      final isSsml = trimmed.startsWith('<speak');
      final inputPayload = isSsml
          ? {
              'ssml': trimmed,
            }
          : {
              'text': trimmed,
            };

      final response = await _dio.post(
        'text:synthesize',
        queryParameters: {'key': apiKey},
        data: {
          'input': inputPayload,
          'voice': {
            'languageCode': 'en-US',
            'name': 'en-US-Neural2-C',
            'ssmlGender': 'FEMALE',
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': 1.0,
            'pitch': 0.0,
          },
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
          'TTS request failed with status code ${response.statusCode}.',
        );
      }

      final audioContent = response.data['audioContent'];
      if (audioContent == null || audioContent is! String) {
        throw Exception('Invalid response from Text-to-Speech API.');
      }

      final bytes = base64Decode(audioContent);
      await _playBytes(bytes);
    } catch (e, stackTrace) {
      print('GoogleTtsService speak error: $e');
      print(stackTrace);
      lastError.value = e.toString();
      isSpeaking.value = false;
      _currentText = null;
      currentText.value = '';
    }
  }

  Future<void> _playBytes(Uint8List bytes) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(BytesSource(bytes));
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    isSpeaking.value = false;
    _currentText = null;
    currentText.value = '';
  }

  @override
  void onClose() {
    _playerCompleteSub?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }
}
