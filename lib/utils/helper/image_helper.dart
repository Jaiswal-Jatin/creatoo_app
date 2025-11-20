import '../../core.dart';

class ImageHelper {
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        print("Original ${await pickedImage.length()} ${pickedImage.path}");
        return await ImageCompressor.compressImage(pickedImage, 50);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
