import '../core/result.dart';
import '../models/attachment.dart';
import '../models/answer.dart';
import '../models/doubt.dart';

abstract class DoubtRepository {
  Future<Result<Doubt>> createDoubt({
    required String question,
    required String attempt,
    required String link,
    required bool isAnonymous,
    required String? authorName,
    required String? authorId,
    required List<String> tags,
    required List<Attachment> attachments,
  });

  Future<Result<List<Doubt>>> fetchFeed({String? topic, String? query});

  Future<Result<List<Doubt>>> fetchMyActivity({required String? authorId, required String? authorName});

  Future<Result<List<Doubt>>> fetchTopAnswers();

  Future<Result<Doubt>> addAnswer({
    required String doubtId,
    required String body,
    required bool isAnonymous,
    required String? authorName,
    required String? authorId,
  });

  Future<Result<Doubt>> toggleUpvote({
    required String doubtId,
    required String voterKey,
  });

  Future<Result<Doubt?>> getById(String doubtId);
}

