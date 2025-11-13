import 'package:html_unescape/html_unescape.dart';

class TextHelpers {
  static String stripSsmlForDisplay(String text) {
    if (text.isEmpty) return text;
    
    final unescape = HtmlUnescape();
    var cleaned = unescape.convert(text);
    
    // Remove SSML tags
    cleaned = cleaned.replaceAll(RegExp(r'<speak[^>]*>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'</speak>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<break[^>]*/>'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'<say-as[^>]*>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'</say-as>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<emphasis[^>]*>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'</emphasis>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]+>'), ''); // Remove any remaining tags
    
    // Clean up extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }
}

