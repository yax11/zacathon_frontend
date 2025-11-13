import 'package:flutter/material.dart';
import '../../app/core/theme/app_colors.dart';

class CollapsibleTextInput extends StatefulWidget {
  const CollapsibleTextInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.expandedWidth = 260,
    this.hintText = 'Type your message...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final double expandedWidth;
  final String hintText;

  @override
  State<CollapsibleTextInput> createState() => _CollapsibleTextInputState();
}

class _CollapsibleTextInputState extends State<CollapsibleTextInput>
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;

  void _toggle() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 56 : widget.expandedWidth,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 24,
              icon: Icon(
                _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                color: AppColors.textSecondary,
              ),
              onPressed: _toggle,
            ),
          ),
          if (!_isCollapsed)
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          if (!_isCollapsed)
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 22,
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: _handleSend,
              ),
            ),
        ],
      ),
    );
  }
}
