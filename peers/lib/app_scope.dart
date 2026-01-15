import 'repositories/doubt_repository.dart';
import 'repositories/mock_doubt_repository.dart';
// import 'repositories/firestore_doubt_repository.dart'; // later

import 'services/session_service.dart';
import 'services/attachment_picker.dart';

class AppScope {
  AppScope._();
  static final AppScope I = AppScope._();

  final SessionService session = SessionService();
  final AttachmentPicker picker = AttachmentPicker();

  final DoubtRepository doubts = MockDoubtRepository();
  // final DoubtRepository doubts = FirestoreDoubtRepository();
}
