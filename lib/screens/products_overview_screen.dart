import 'package:flutter/material.dart';

import '../widgets/productsgrid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha loja'),
      ),
      body: ProductsGrid(),
    );
  }
}
