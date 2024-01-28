import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerFunctions {
  Future<List<File>> filePicker({
    FileType type = FileType.media,
    bool allowMultiple = true,
  }) async {
    final List<File> files = <File>[];
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: type,
    );
    if (result == null) return files;
    for (PlatformFile element in result.files) {
      files.add(File(element.path!));
    }
    return files;
  }

  Future<XFile?> camera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    return image;
  }
}
