import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/theme/app_colors.dart';

class AccountOcrView extends StatefulWidget {
  const AccountOcrView({super.key});

  @override
  State<AccountOcrView> createState() => _AccountOcrViewState();
}

class _AccountOcrViewState extends State<AccountOcrView> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final bool _detectNumbersOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = controller.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;
      setState(() {
        _controller = controller;
      });
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Camera Error',
        'Unable to start camera. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    setState(() => _isProcessing = true);
    try {
      final file = await _controller!.takePicture();
      final result = await _processImage(file);

      if (!mounted) return;
      if (result != null) {
        Get.back(result: result);
      } else {
        Get.snackbar(
          'Not Found',
          'No valid account number detected. Adjust the card and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Scan Failed',
        'An error occurred while scanning. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<String?> _processImage(XFile file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    final recognisedText = await _textRecognizer.processImage(inputImage);

    final rawText = recognisedText.text.trim();
    if (rawText.isEmpty) {
      return null;
    }

    if (_detectNumbersOnly) {
      final digitsOnly = rawText.replaceAll(RegExp(r'[^0-9]'), ' ').split(' ');

      for (final token in digitsOnly) {
        if (token.length >= 10) {
          return token.substring(0, 10);
        }
      }
      return null;
    }

    return rawText;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: controller == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      CameraPreview(controller),
                      const ScannerOverlay(),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Align the account details within the box, then tap capture.',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _isProcessing ? null : _captureAndProcess,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isProcessing
                                        ? Colors.grey
                                        : AppColors.primary,
                                    width: 4,
                                  ),
                                ),
                                child: _isProcessing
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.document_scanner_outlined,
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScannerOverlayPainter(),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double borderRadius = 16;
  final double borderWidth = 3;
  final Color borderColor = AppColors.primary;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.white.withOpacity(0.75);
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutOutWidth = size.width * 0.85;
    final cutOutHeight = size.height * 0.22;
    final cutOutLeft = (size.width - cutOutWidth) / 2;
    final cutOutTop = (size.height - cutOutHeight) / 2.5;

    final cutOutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cutOutLeft, cutOutTop, cutOutWidth, cutOutHeight),
      Radius.circular(borderRadius),
    );

    final cutOutPath = Path()..addRRect(cutOutRect);

    final overlayPath =
        Path.combine(PathOperation.difference, path, cutOutPath);

    canvas.drawPath(overlayPath, overlayPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(cutOutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
