import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/CommonPages/image_screen.dart';
import '../utils/constants.dart';

class RoundedNetworkAvatar extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  final double border;
  final String? url;

  // final String? prefix;
  final BoxFit? fit;

  RoundedNetworkAvatar({
    Key? key,
    this.height = 50.0,
    this.width = 50.0,
    this.border = 2.0,
    required this.url,
    this.fit = BoxFit.cover,
    this.color = Colors.white,
    // this.prefix = MK_Apis.storagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: border, color: color),
            borderRadius: BorderRadius.circular(40)),
        // radius: 25,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: url != null
                ? ImageWithPlaceholder(
                    image: "$url",
                    fit: fit,
                    width: width,
                    height: height,
                    // prefix: '${prefix != null ? "$prefix" : ""}',
                  )
                : Image.asset(
                    PLACEHOLDER_IAMGE_PATH,
                    height: height,
                    width: width,
                    fit: fit,
                  ),
          ),
        ));
  }
}

class ImageWithPlaceholder extends StatelessWidget {
  const ImageWithPlaceholder({
    Key? key,
    required this.image,
    // this.prefix = MK_Apis.storagePath,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
    this.shouldEnlarge = true,
  }) : super(key: key);

  final String? image;

  // final String? prefix;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool shouldEnlarge;

  String generateRandomTag() {
    int randomNum = Random().nextInt(
        100000); // Generate a random number between 0 and 100000 Generate a random string of 5 alphanumeric characters
    return 'tag-$randomNum'; // Combine the random number and random string to create the tag
  }

  @override
  Widget build(BuildContext context) {
    // log('MK: image url: "$prefix$image"');

    String tag = generateRandomTag();
    return image != null && image != ""
        ? CachedNetworkImage(
            imageUrl: "$image",
            height: height,
            width: width,
            fit: fit,
            cacheKey: '$image',
            imageBuilder: (context, imageProvider) => InkWell(
                  onTap: shouldEnlarge
                      ? () async {
                          // await CachedNetworkImage.evictFromCache("$prefix$image");
                          Get.to(ImageScreen(
                            imageUrl: image!,
                            tag: tag,
                          ));
                        }
                      : null,
                  child: Hero(
                    tag: tag,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: fit,
                          // colorFilter:
                          //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                        ),
                      ),
                    ),
                  ),
                ),
            placeholder: (context, url) => Stack(
                  children: <Widget>[
                    // Show a blurred version of the image
                    Image.network("$image"),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.white.withOpacity(0),
                      ),
                    ),
                    // Center(
                    //   child: CircularProgressIndicator(),
                    // ),
                  ],
                ),
            // errorWidget: (context, url, error) => Icon(Icons.error),
            errorWidget: (context, url, error) => GestureDetector(
                  onTap: () async {
                    await CachedNetworkImage.evictFromCache(url);
                  },
                  child: Image.asset(
                    PLACEHOLDER_IAMGE_PATH,
                    height: height,
                    width: width,
                    fit: fit,
                  ),
                ))
        : Image.asset(
            PLACEHOLDER_IAMGE_PATH,
            height: height,
            width: width,
            fit: fit,
          );
  }
}

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: primaryColor,
    ));
  }
}
