import 'package:flutter/material.dart';

class CatalogsScreen extends StatelessWidget {
  const CatalogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Catalogs')),
      body: const Center(
        child: Text('Manage your rating lists (Coming Soon)'),
      ),
    );
  }
}
