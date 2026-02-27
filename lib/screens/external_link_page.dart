import 'package:flutter/material.dart';

class ExternalLinkPage extends StatelessWidget {
  const ExternalLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('External Link')),
      body: const Center(child: Text('Connecting to Vendor...')),
    );
  }
}
