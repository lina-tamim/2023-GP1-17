import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage(
      {required this.imageURL,
      this.fit,
      this.color,
      this.height,
      this.width,
      Key? key})
      : super(key: key);
  final String imageURL;
  final BoxFit? fit;
  final Color? color;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageURL,
      fit: fit,
      color: color,
      height: height,
      width: width,
      progressIndicatorBuilder: (BuildContext context, String url,
              DownloadProgress downloadProgress) =>
          const ShowLoading(),
      errorWidget: (BuildContext context, String url, dynamic _) =>
          const Icon(Icons.error, color: Colors.grey),
    );
  }
}

class ShowLoading extends StatelessWidget {
  const ShowLoading({this.backgroundColor, Key? key}) : super(key: key);
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator.adaptive(
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
