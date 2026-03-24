import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// 카메라 및 갤러리에서 이미지를 가져오는 서비스
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// 카메라로 사진 촬영
  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// 갤러리에서 사진 선택
  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
