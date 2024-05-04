import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class StringUtils {
  static convertImageToBase64(XFile fileData) async {
    List<int> imageBytes = await fileData.readAsBytes();
    return base64Encode(imageBytes);
  }

  static convertBase64ToImage(String imageString) {
    return base64Decode(imageString);
  }
}
