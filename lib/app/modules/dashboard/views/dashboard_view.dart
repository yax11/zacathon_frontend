import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../overview/views/overview_view.dart';
import '../../overview/controllers/overview_controller.dart';
import '../../airtime/views/airtime_view.dart';
import '../../zai/views/zai_view.dart';
import '../../transfer/views/transfer_view.dart';
import '../../bills/views/bills_view.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/services/tts/google_tts_service.dart';
import '../../../../widgets/icons/huge_icon_compat.dart';
import '../../../core/utils/text_helpers.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              OverviewView(),
              AirtimeView(),
              ZaiView(),
              TransferView(),
              BillsView(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ));
  }

  // Method to refresh current tab
  void refreshCurrentTab() {
    if (controller.currentIndex.value == 0) {
      // Refresh overview if it's the current tab
      if (Get.isRegistered<OverviewController>()) {
        Get.find<OverviewController>().refreshData();
      }
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          // Intercept zAI item (index 2) to open a bottom sheet
          if (index == 2) {
            _showAIModal(context);
            return;
          }
          controller.changeTab(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: controller.menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final List<List<dynamic>>? hugeIcon =
              item['hugeIcon'] as List<List<dynamic>>?;
          final iconData = item['iconData'] as IconData?;

          // Special circular primary background for the middle zAI icon
          Widget buildZaiIcon() {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData ?? Icons.smart_toy_outlined,
                    color: AppColors.textWhite,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'zen AI',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return BottomNavigationBarItem(
            icon: index == 2
                ? buildZaiIcon()
                : _buildMenuIcon(
                    hugeIcon: hugeIcon, iconData: iconData, isActive: false),
            label: index == 2 ? '' : item['title'] as String,
            activeIcon: index == 2
                ? buildZaiIcon()
                : _buildMenuIcon(
                    hugeIcon: hugeIcon, iconData: iconData, isActive: true),
          );
        }).toList(),
      ),
    );
  }

  void _showAIModal(BuildContext context) {
    controller.prepareAIModal();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ZenAiModal(controller: controller),
    ).whenComplete(() {
      controller.resetSpeech();
    });
  }

  Widget _buildMenuIcon({
    List<List<dynamic>>? hugeIcon,
    IconData? iconData,
    required bool isActive,
  }) {
    final color = isActive ? AppColors.primary : AppColors.textLight;
    if (hugeIcon != null) {
      return HugeIconCompat(
        icon: hugeIcon,
        color: color,
        size: 26,
      );
    }
    if (iconData != null) {
      return Icon(
        iconData,
        color: color,
      );
    }
    return Icon(
      Icons.circle,
      color: color,
    );
  }
}

class _ZenAiModal extends StatefulWidget {
  const _ZenAiModal({required this.controller});

  final DashboardController controller;

  @override
  State<_ZenAiModal> createState() => _ZenAiModalState();
}

class _ZenAiModalState extends State<_ZenAiModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final Worker _listeningWorker;
  late final Worker _responseWorker;
  bool _introCompleted = false;
  bool _lottieInitialized = false;
  final GoogleTtsService _ttsService = Get.find<GoogleTtsService>();
  String? _lastSpokenResponse;

  DashboardController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.prepareAIModal();
    _lottieController = AnimationController(vsync: this);
    _listeningWorker = ever<bool>(_controller.isListening, (listening) {
      if (!mounted) return;
      if (listening) {
        if (_introCompleted) {
          _lottieController.repeat();
        }
      } else if (_introCompleted) {
        _lottieController.stop();
        _lottieController.animateTo(1,
            duration: const Duration(milliseconds: 300));
      }
    });
    // Listen for AI response changes and speak them
    _responseWorker = ever<String>(_controller.aiResponse, (response) {
      if (response.isNotEmpty && response != _lastSpokenResponse) {
        _lastSpokenResponse = response;
        _speakResponse(response);
      }
    });
  }

  Future<void> _speakResponse(String text) async {
    await _ttsService.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _ttsService.stop();
  }

  @override
  void dispose() {
    _listeningWorker.dispose();
    _responseWorker.dispose();
    _ttsService.stop();
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!_introCompleted) return;
    if (_controller.isListening.value) {
      await _controller.stopListening();
    } else {
      await _controller.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline,
                      color: AppColors.primary),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.zai);
                  },
                  tooltip: 'Open Chat',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _handleTap,
                child: Obx(() {
                  final level = _controller.soundLevel.value;
                  final normalized = (level / 40).clamp(0.0, 1.0);
                  final baseSize = 160.0;
                  final size =
                      _introCompleted ? baseSize + (normalized * 60) : baseSize;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: size,
                    height: size,
                    child: Lottie.asset(
                      'assets/animations/zenAI.json',
                      controller: _lottieController,
                      repeat: false,
                      animate: false,
                      onLoaded: (composition) {
                        if (_lottieInitialized) return;
                        _lottieInitialized = true;
                        _lottieController
                          ..duration = composition.duration
                          ..forward().whenComplete(() {
                            if (!mounted) return;
                            setState(() {
                              _introCompleted = true;
                            });
                          });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            if (_introCompleted) ...[
              Container(),
              const SizedBox(height: 12),
              Obx(() => Center(
                    child: Text(
                      _controller.isListening.value
                          ? 'Listening...'
                          : (_controller.isProcessing.value
                              ? 'Processing...'
                              : 'Tap to speak.'),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )),
              // Display recognized text
              Obx(() {
                if (_controller.recognizedText.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'You said: ${_controller.recognizedText.value}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              // Display AI response
              Obx(() {
                if (_controller.aiResponse.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Obx(() {
                      final isSpeaking = _ttsService.isSpeaking.value;
                      final responseText = TextHelpers.stripSsmlForDisplay(
                          _controller.aiResponse.value);

                      // Check if text exceeds 3 lines
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: responseText,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        maxLines: 3,
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(
                          maxWidth: MediaQuery.of(context).size.width - 120);
                      final exceedsThreeLines = textPainter.didExceedMaxLines;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(AppRoutes.zai);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Text(
                                          responseText,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.clip,
                                        ),
                                        if (exceedsThreeLines)
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: IgnorePointer(
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      AppColors.primary
                                                          .withOpacity(0.0),
                                                      AppColors.primary
                                                          .withOpacity(0.1),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSpeaking)
                                    SizedBox(
                                      width: 60,
                                      height: 28,
                                      child: Lottie.asset(
                                        'assets/animations/wave-voice.json',
                                        repeat: true,
                                      ),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(
                                        Icons.volume_up,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () => _speakResponse(
                                          _controller.aiResponse.value),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isSpeaking)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextButton.icon(
                                onPressed: _stopSpeaking,
                                icon: const Icon(Icons.stop, size: 16),
                                label: const Text('Stop'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  );
                }
                return const SizedBox.shrink();
              }),
            ] else ...[
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Preparing zen AI...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
