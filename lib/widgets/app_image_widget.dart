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
    final imageUrl = _getImageUrl(this.imageUrl);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl.isNotEmpty 
          ? CachedNetworkImage(
              alignment: Alignment.center,
              height: height,
              width: width,
              imageUrl: imageUrl,
              fit: fit,
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
            )
          : isProfile
              ? Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: iconSize,
                    color: Colors.grey,
                  ),
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: iconSize,
                    color: Colors.grey,
                  ),
                ),
      ),
    );
  }
}
