import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  final ImagePicker _picker = ImagePicker();

  ImagePickerUtil();

  /// Picks images from gallery or camera.
  Future<List<XFile>> pickImages({
    required ImageSource source,
    required int maxFileLimit,
    int imageQuality = 100,
  }) async {
    try {
      if (source == ImageSource.gallery) {
        return await _picker.pickMultiImage(
          limit: maxFileLimit,
          imageQuality: imageQuality,
        );
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: imageQuality,
        );
        return image != null ? [image] : [];
      }
    } catch (e) {
      debugPrint('ImagePickerUtil error: $e');
      rethrow;
    }
  }
}
