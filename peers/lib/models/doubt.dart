import 'attachment.dart';
import 'answer.dart';

class Doubt {
  final String id;
  final String question;
  final String attempt;
  final String link;

  final bool isAnonymous;
  final String? authorName;
  final String? authorId;

  final List<String> tags;
  final List<Attachment> attachments;
  final DateTime createdAt;

  final int upvotes;
  final int answers;
  final List<Answer> answerList;

  const Doubt({
    required this.id,
    required this.question,
    required this.attempt,
    required this.link,
    required this.isAnonymous,
    required this.authorName,
    required this.authorId,
    required this.tags,
    required this.attachments,
    required this.createdAt,
    this.upvotes = 0,
    this.answers = 0,
    this.answerList = const [],
  });

  Doubt copyWith({
    int? upvotes,
    int? answers,
    List<Answer>? answerList,
  }) {
    return Doubt(
      id: id,
      question: question,
      attempt: attempt,
      link: link,
      isAnonymous: isAnonymous,
      authorName: authorName,
      authorId: authorId,
      tags: tags,
      attachments: attachments,
      createdAt: createdAt,
      upvotes: upvotes ?? this.upvotes,
      answers: answers ?? this.answers,
      answerList: answerList ?? this.answerList,
    );
  }
}

