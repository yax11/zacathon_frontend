import 'package:flutter/material.dart';

class AirtimeView extends StatelessWidget {
  const AirtimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airtime'),
      ),
      body: const Center(
        child: Text(
          'Airtime',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

