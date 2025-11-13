import 'package:flutter/material.dart';
import '../../../app/core/theme/app_colors.dart';
import '../inputs/pin_input_widget.dart';

class PinVerificationBottomSheet extends StatefulWidget {
  final String transactionId;
  final String message;
  final Future<Map<String, dynamic>> Function(String transactionId, String pin) onVerify;

  const PinVerificationBottomSheet({
    super.key,
    required this.transactionId,
    required this.message,
    required this.onVerify,
  });

  @override
  State<PinVerificationBottomSheet> createState() => _PinVerificationBottomSheetState();
}

class _PinVerificationBottomSheetState extends State<PinVerificationBottomSheet> {
  bool _isVerifying = false;
  String? _errorMessage;
  final GlobalKey _pinInputKey = GlobalKey();

  Future<void> _handlePinComplete(String pin) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onVerify(widget.transactionId, pin);
      
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        if (result['success'] == true) {
          // Close immediately on success
          if (mounted) {
            Navigator.pop(context, result);
          }
          return;
        } else {
          setState(() {
            _errorMessage = result['message'] as String?;
          });
          
          // If transaction expired, close after a delay
          if (result['isExpired'] == true) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context, result);
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'An error occurred. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          const Text(
            'Verify Transaction',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // PIN Input Widget
          if (_isVerifying)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            PinInputWidget(
              key: _pinInputKey,
              onPinComplete: _handlePinComplete,
              errorMessage: _errorMessage,
            ),
          const SizedBox(height: 24),
          // Cancel Button
          TextButton(
            onPressed: _isVerifying
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

