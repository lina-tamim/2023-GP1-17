import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:techxcel11/pages/CommonPages/image_screen.dart';
import 'package:techxcel11/pages/UserPages/UserProfileView.dart';
import 'package:techxcel11/utils/constants.dart';

//import '../pages/CommonPages/image_screen.dart';
//import '../pages/UserPages/UserProfileView.dart';
//import '../utils/constants.dart';

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

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({
    super.key,
    required this.userId,
    required this.child,
    this.title,
    required this.description,
    required this.postedDate,
  });

  final String userId;
  final String? title;
  final String description;
  final Widget child;
  final DateTime postedDate;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      // log('MK: fetching user data for ${userId}');

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('RegularUser')
              .where('email', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        // final userData = snapshot.docs[0].data();
        Map<String, dynamic> userData = snapshot.docs[0].data();
        return userData;
      } else {
        // User not found
        return {};
      }
    } catch (e) {
      // Error fetching user data
      print('Error fetching user data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserData(userId),
        // Call the getUserData function to fetch user data
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          Map userData = {};
          String username = '';
          String? userPhotoUrl = '';
          String userType = "";

          if (snapshot.connectionState == ConnectionState.waiting) {
          } else if (snapshot.hasError) {
            // Show error message if there's an error fetching user data
            // log('Error fetching user data: ${snapshot.error}');
            username = 'DeactivatedUser';
          } else {
            userData = snapshot.data!;
            username = userData['username'] as String? ?? '';
            userPhotoUrl = userData['imageURL'] as String? ?? '';
            userType = userData['userType'] as String? ?? "";
          }

          return ListTile(
            leading: CircleAvatar(
              radius: 30, // Adjust the radius to make the avatar bigger
              backgroundImage: userPhotoUrl != ''
                  ? NetworkImage(userPhotoUrl)
                  : const AssetImage('assets/Backgrounds/defaultUserPic.png')
                      as ImageProvider<Object>, // Cast to ImageProvider<Object>
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (userId.isNotEmpty && username != "DeactivatedUser") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileView(userId: userId),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (username.isNotEmpty)
                              Expanded(
                                child: Text(
                                  username ?? '',
                                  // Display the username
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 24, 8, 53),
                                      fontSize: 16),
                                ),
                              )
                            else
                              Container(
                                height: 20,
                                width: 130,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            if (userType == "Freelancer")
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.deepPurple,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(postedDate),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.4,
                    ),
                  ),
                SizedBox(height: 5),
                Text(description,
                    style: TextStyle(
                      fontSize: 15,
                    )),
              ],
            ),
            subtitle: child,
          );
        });
  }
}
