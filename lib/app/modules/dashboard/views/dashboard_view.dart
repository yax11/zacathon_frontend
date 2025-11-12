import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../overview/views/overview_view.dart';
import '../../airtime/views/airtime_view.dart';
import '../../zai/views/zai_view.dart';
import '../../transfer/views/transfer_view.dart';
import '../../bills/views/bills_view.dart';
import '../controllers/dashboard_controller.dart';

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
          final iconAsset = item['iconAsset'] as String?;
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
                    iconAsset: iconAsset, iconData: iconData, isActive: false),
            label: index == 2 ? '' : item['title'] as String,
            activeIcon: index == 2
                ? buildZaiIcon()
                : _buildMenuIcon(
                    iconAsset: iconAsset, iconData: iconData, isActive: true),
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
    String? iconAsset,
    IconData? iconData,
    required bool isActive,
  }) {
    if (iconAsset != null) {
      return Image.asset(
        iconAsset,
        width: 24,
        height: 24,
        color: isActive ? AppColors.primary : AppColors.textLight,
      );
    }
    return Icon(
      iconData ?? Icons.circle,
      color: isActive ? AppColors.primary : AppColors.textLight,
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
  bool _introCompleted = false;
  bool _lottieInitialized = false;

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
  }

  @override
  void dispose() {
    _listeningWorker.dispose();
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
                          : 'Tap to speak.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )),
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
