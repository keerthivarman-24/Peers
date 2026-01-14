class Answer {
  final String id;
  final String body;
  final bool isAnonymous;
  final String? authorName;
  final String? authorId;
  final DateTime createdAt;
  final int upvotes;

  const Answer({
    required this.id,
    required this.body,
    required this.isAnonymous,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    this.upvotes = 0,
  });
}

