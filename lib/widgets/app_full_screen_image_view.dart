import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../resources/app_url.dart';
import '../resources/color.dart';

class FullScreenImageCarouselView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageCarouselView({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: AppColor.transparent,
      appBar: AppBar(
        backgroundColor: AppColor.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        pageController: pageController,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (context, index) {
          final imageUrl = imageUrls[index];
          final fullUrl = imageUrl.startsWith("http") ? imageUrl : "${AppUrl.host}/storage/app/$imageUrl";

          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(fullUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: fullUrl),
          );
        },
        backgroundDecoration: BoxDecoration(color: AppColor.transparent),
      ),
    );
  }
}
