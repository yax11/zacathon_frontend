import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HugeIconCompat extends StatelessWidget {
  const HugeIconCompat({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.strokeWidth,
  });

  final List<List<dynamic>> icon;
  final double size;
  final Color? color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        Colors.black;
    final svgString = _buildSvgFromJson(icon, effectiveColor, strokeWidth);
    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
    );
  }

  String _buildSvgFromJson(List<List<dynamic>> iconData, Color effectiveColor,
      double? strokeWidthOverride) {
    final buffer = StringBuffer();
    buffer.write(
        '<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">');

    final hexColor = '#${effectiveColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    for (final element in iconData) {
      final tagName = element[0] as String;
      final attributes = element[1] as Map<String, dynamic>;

      buffer.write('<$tagName');

      for (final entry in attributes.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key == 'key') {
          continue;
        }

        String finalValue = value.toString();
        if ((key == 'stroke' || key == 'fill') && value == 'currentColor') {
          finalValue = hexColor;
        } else if (key == 'strokeWidth' && strokeWidthOverride != null) {
          finalValue = strokeWidthOverride.toString();
        }

        String svgAttrName = key;
        if (key == 'strokeWidth') {
          svgAttrName = 'stroke-width';
        } else if (key == 'strokeLinecap') {
          svgAttrName = 'stroke-linecap';
        } else if (key == 'strokeLinejoin') {
          svgAttrName = 'stroke-linejoin';
        } else if (key == 'fillRule') {
          svgAttrName = 'fill-rule';
        } else if (key == 'clipRule') {
          svgAttrName = 'clip-rule';
        }

        buffer.write(' $svgAttrName="$finalValue"');
      }

      buffer.write('/>');
    }

    buffer.write('</svg>');
    return buffer.toString();
  }
}
