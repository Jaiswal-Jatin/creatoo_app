import '../core.dart';

class AppImageWidget extends StatelessWidget {
  final double height;
  final double width;
  final double iconSize;
  final String imageUrl;
  final BoxFit fit;
  final double borderRadius;
  final bool isProfile;

  AppImageWidget({
    this.height = 120,
    this.width = 120,
    this.iconSize = 65,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.borderRadius = 10,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300), // Added border to the image
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          alignment: Alignment.center,
          height: height,
          width: width,
          imageUrl: "$baseUrl$imageUrl",
          fit: BoxFit.cover,
          placeholder: ImagePlaceholderWidget,
          errorWidget: isProfile
              ? (ctx, url, error) => SizedBox(
                    width: width,
                    height: height,
                    child: ClipOval(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: iconSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
              : ImageErrorWidget,
        ),
      ),
    );
  }
}
