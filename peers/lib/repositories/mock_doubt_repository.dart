import 'dart:math';

import '../core/result.dart';
import '../models/answer.dart';
import '../models/attachment.dart';
import '../models/doubt.dart';
import 'doubt_repository.dart';

class MockDoubtRepository implements DoubtRepository {
  final List<Doubt> _db = [];
  final Map<String, Set<String>> _votes = {}; // doubtId -> voter keys

  MockDoubtRepository() {
    // seed some sample data
    final now = DateTime.now();
    _db.addAll([
      Doubt(
        id: _id(),
        question: 'Why does current lead voltage in a capacitor?',
        attempt: 'I know i = C dv/dt but need intuition.',
        link: '',
        isAnonymous: true,
        authorName: null,
        authorId: null,
        tags: const ['Circuits', 'Physics'],
        attachments: const [],
        createdAt: now.subtract(const Duration(hours: 4)),
        upvotes: 6,
        answers: 2,

        answerList: [
          Answer(
            id: 'a1',
            body: '...',
            isAnonymous: false,
            authorName: 'Senior',
            authorId: 'u2',
            createdAt: now.subtract(const Duration(days: 3)),
            upvotes: 3,
          ),
          Answer(
            id: 'a2',
            body: '...',
            isAnonymous: true,
            authorName: null,
            authorId: null,
            createdAt: now.subtract(const Duration(days: 2)),
            upvotes: 2,
          ),
        ],
      ),
      Doubt(
        id: _id(),
        question: 'Flutter: setState vs Provider — when to use what?',
        attempt: 'I can build UI but state mgmt confuses me.',
        link: 'https://flutter.dev',
        isAnonymous: false,
        authorName: 'Keerthi',
        authorId: 'u1',
        tags: const ['Flutter', 'Programming'],
        attachments: const [],
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        upvotes: 4,
        answers: 0,
      ),
    ]);
  }

  String _id() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

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
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final d = Doubt(
      id: _id(),
      question: question,
      attempt: attempt,
      link: link,
      isAnonymous: isAnonymous,
      authorName: isAnonymous ? null : authorName,
      authorId: authorId,
      tags: tags,
      attachments: attachments,
      createdAt: DateTime.now(),
      upvotes: 0,
      answers: 0,
      answerList: const [],
    );

    _db.insert(0, d);
    return Result.ok(d);
  }

  @override
  Future<Result<List<Doubt>>> fetchFeed({String? topic, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final q = (query ?? '').trim().toLowerCase();

    final list = _db.where((d) {
      final matchTopic =
          topic == null || topic.isEmpty || d.tags.contains(topic);
      final matchQuery =
          q.isEmpty ||
          d.question.toLowerCase().contains(q) ||
          d.attempt.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q));
      return matchTopic && matchQuery;
    }).toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Result.ok(list);
  }

  @override
  Future<Result<List<Doubt>>> fetchMyActivity({
    required String? authorId,
    required String? authorName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));

    final list = _db.where((d) {
      if (authorId != null && authorId.isNotEmpty)
        return d.authorId == authorId;
      if (authorName != null && authorName.isNotEmpty)
        return d.authorName == authorName;
      return false;
    }).toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Result.ok(list);
  }

  @override
  Future<Result<List<Doubt>>> fetchTopAnswers() async {
    await Future.delayed(const Duration(milliseconds: 180));
    final list = [..._db]..sort((a, b) => b.answers.compareTo(a.answers));
    return Result.ok(list.take(30).toList());
  }

  @override
  Future<Result<Doubt>> addAnswer({
    required String doubtId,
    required String body,
    required bool isAnonymous,
    required String? authorName,
    required String? authorId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));

    final idx = _db.indexWhere((d) => d.id == doubtId);
    if (idx < 0) return const Result.err('Doubt not found');

    final d = _db[idx];
    final newAnswer = Answer(
      id: _id(),
      body: body,
      isAnonymous: isAnonymous,
      authorName: isAnonymous ? null : authorName,
      authorId: authorId,
      createdAt: DateTime.now(),
      upvotes: 0,
    );

    final newList = [...d.answerList, newAnswer];
    final updated = d.copyWith(answerList: newList, answers: newList.length);

    _db[idx] = updated;
    return Result.ok(updated);
  }

  @override
  Future<Result<Doubt>> toggleUpvote({
    required String doubtId,
    required String voterKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));

    final idx = _db.indexWhere((d) => d.id == doubtId);
    if (idx < 0) return const Result.err('Doubt not found');

    final set = _votes.putIfAbsent(doubtId, () => <String>{});
    final d = _db[idx];

    if (set.contains(voterKey)) {
      set.remove(voterKey);
    } else {
      set.add(voterKey);
    }

    final updated = d.copyWith(upvotes: set.length);
    _db[idx] = updated;
    return Result.ok(updated);
  }

  @override
  Future<Result<Doubt?>> getById(String doubtId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final d = _db.where((x) => x.id == doubtId).toList();
    return Result.ok(d.isEmpty ? null : d.first);
  }
}
