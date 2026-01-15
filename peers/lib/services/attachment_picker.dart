import 'dart:math';
import '../models/attachment.dart';

class AttachmentPicker {
  Future<List<Attachment>> pickFiles() async {
    // TODO (later): integrate file_picker / image_picker.
    // For now: keep it empty so the app works without extra deps.
    return [];
  }

  String newId() => '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
}

