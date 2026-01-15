import '../core/result.dart';
import '../models/attachment.dart';
import '../models/doubt.dart';
import 'doubt_repository.dart';

class FirestoreDoubtRepository implements DoubtRepository {
  // TODO (later): connect to Firebase Firestore / Storage.
  // Suggested collections:
  // - doubts (documents)
  // - doubts/{doubtId}/answers (subcollection)
  // - doubts/{doubtId}/votes/{uid} (prevent multiple votes)

  @override
  Future<Result<Doubt>> createDoubt({
    required String question,
    required String attempt,
    required String link,
    required bool isAnonymous,
    required String? authorName,
    required String? authorId,
    required List<String> tags,
    required List<Attachment> attachments,
  }) {
    throw UnimplementedError('Connect to Firestore later');
  }

  @override
  Future<Result<List<Doubt>>> fetchFeed({String? topic, String? query}) {
    throw UnimplementedError('Connect to Firestore later');
  }

  @override
  Future<Result<List<Doubt>>> fetchMyActivity({
    required String? authorId,
    required String? authorName,
  }) {
    throw UnimplementedError('Connect to Firestore later');
  }

  @override
  Future<Result<List<Doubt>>> fetchTopAnswers() {
    throw UnimplementedError('Connect to Firestore later');
  }

  @override
  Future<Result<Doubt>> addAnswer({
    required String doubtId,
    required String body,
    required bool isAnonymous,
    required String? authorName,
    required String? authorId,
  }) {
    throw UnimplementedError('Connect to Firestore later');
  }

  @override
  Future<Result<Doubt>> toggleUpvote({
    required String doubtId,
    required String voterKey,
  }) {
    throw UnimplementedError('Connect to Firestore later');
  }

  @override
  Future<Result<Doubt?>> getById(String doubtId) {
    throw UnimplementedError('Connect to Firestore later');
  }
}
