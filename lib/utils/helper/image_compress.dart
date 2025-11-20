import 'package:creatoo/core.dart';

class ImageCompressor {
  static Future<File?> compressImage(XFile? imageFile, int quality) async {
    if (imageFile == null) return null;

    String filePath = imageFile.path;
    String compressedFilePath = '${filePath.substring(0, filePath.lastIndexOf('.'))}_compressed.${filePath.split('.').last}';
    String format = "${filePath.split('.').last}";
    XFile? file =  await FlutterImageCompress.compressAndGetFile(
      filePath,
      compressedFilePath,
      quality: quality,
      format: format == "png" ? CompressFormat.png: CompressFormat.jpeg
    );
    return File(file!.path);
  }
}
