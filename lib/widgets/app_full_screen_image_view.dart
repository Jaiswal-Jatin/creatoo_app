import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../resources/color.dart';

class FullScreenImageCarouselView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageCarouselView({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  String _getImageUrl(String url) {
    if (url.isEmpty) return '';
    
    // If already a full URL, return as is
    if (url.startsWith('http')) {
      return url;
    }
    
    // Handle cases where the URL might already have a leading slash
    final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    
    // Return the full DigitalOcean Spaces URL
    return 'https://creatoos3.blr1.digitaloceanspaces.com/images/$cleanUrl';
  }

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
          final imageUrl = _getImageUrl(imageUrls[index]);
          
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          );
        },
        backgroundDecoration: BoxDecoration(color: AppColor.transparent),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            ),
          ),
        ),
      ),
    );
  }
}
