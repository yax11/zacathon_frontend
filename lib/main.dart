import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize GetStorage
    await GetStorage.init();

    // Try to load .env file with multiple strategies
    bool envLoaded = false;

    // Strategy 1: Try loading from root directory (development)
    try {
      await dotenv.load(fileName: ".env");
      print('Successfully loaded .env file from root directory');
      envLoaded = true;
    } catch (e) {
      print('Failed to load .env from root (standard method): $e');
    }

    // Strategy 2: If root loading failed, try loading from assets with encoding handling
    if (!envLoaded) {
      try {
        // Load from assets as bytes to handle encoding issues
        final ByteData data = await rootBundle.load('.env');
        // Try to decode with UTF-8, replacing invalid characters
        String envString;
        try {
          envString =
              utf8.decode(data.buffer.asUint8List(), allowMalformed: true);
        } catch (e) {
          // If UTF-8 fails, try Latin-1 as fallback
          envString = latin1.decode(data.buffer.asUint8List());
        }

        // Parse the string manually
        final lines = LineSplitter.split(envString);
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
            continue;
          }
          final index = trimmedLine.indexOf('=');
          if (index > 0) {
            final key = trimmedLine.substring(0, index).trim();
            final value = trimmedLine.substring(index + 1).trim();
            // Remove quotes if present
            String cleanValue = value;
            if (cleanValue.startsWith('"') && cleanValue.endsWith('"')) {
              cleanValue = cleanValue.substring(1, cleanValue.length - 1);
            } else if (cleanValue.startsWith("'") && cleanValue.endsWith("'")) {
              cleanValue = cleanValue.substring(1, cleanValue.length - 1);
            }
            dotenv.env[key] = cleanValue;
          }
        }
        print('Successfully loaded .env file from assets (with encoding fix)');
        envLoaded = true;
      } catch (e) {
        print('Failed to load .env from assets: $e');
      }
    }

    if (!envLoaded) {
      print('Warning: Could not load .env file from any source.');
      print('Continuing without .env file. Services will use fallback values.');
    }
  } catch (e) {
    print('Error during initialization: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Zen AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
