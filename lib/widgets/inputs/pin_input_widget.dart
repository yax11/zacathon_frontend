import 'package:flutter/material.dart';
import '../../../app/core/theme/app_colors.dart';

class PinInputWidget extends StatefulWidget {
  final Function(String) onPinComplete;
  final int pinLength;
  final String? errorMessage;

  const PinInputWidget({
    super.key,
    required this.onPinComplete,
    this.pinLength = 4,
    this.errorMessage,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  String _pin = '';

  @override
  void didUpdateWidget(PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear PIN when error message changes (new error)
    if (widget.errorMessage != null && 
        widget.errorMessage != oldWidget.errorMessage &&
        widget.errorMessage!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _pin = '';
          });
        }
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < widget.pinLength) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == widget.pinLength) {
        widget.onPinComplete(_pin);
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) => Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _pin.length
                    ? AppColors.primary
                    : AppColors.border,
                border: Border.all(
                  color: index < _pin.length
                      ? AppColors.primary
                      : AppColors.border,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 24),
        // Number Pad
        Column(
          children: [
            _buildNumberRow(['1', '2', '3']),
            const SizedBox(height: 16),
            _buildNumberRow(['4', '5', '6']),
            const SizedBox(height: 16),
            _buildNumberRow(['7', '8', '9']),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  label: 'Clear',
                  onPressed: _onClearPressed,
                  isAction: true,
                ),
                const SizedBox(width: 16),
                _buildNumberButton('0'),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.backspace,
                  onPressed: _onDeletePressed,
                  isAction: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers
          .map((number) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildNumberButton(number),
              ))
          .toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    String? label,
    IconData? icon,
    required VoidCallback onPressed,
    required bool isAction,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAction ? AppColors.textSecondary.withOpacity(0.1) : AppColors.background,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: AppColors.textPrimary,
                    size: 24,
                  )
                : Text(
                    label ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

