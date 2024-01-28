import 'package:flutter/material.dart';

import '../../utils/functions/public_methods.dart';

class ImageScreen extends StatelessWidget {
  final String imageUrl;
  final String tag;

  ImageScreen({required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragDown: (dynamic details) => Navigator.of(context).pop(),
        // onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: tag,
            child: Image.network(
              imageUrl,
              fit: BoxFit.fill,
              width: getWidth(context),
            ),
          ),
        ),
      ),
    );
  }
}
