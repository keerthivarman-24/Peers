class Attachment {
  final String id;
  final String name;
  final String path; // local path for now
  final String? url; // cloud url later
  final int? bytes;

  const Attachment({
    required this.id,
    required this.name,
    required this.path,
    this.url,
    this.bytes,
  });

  Attachment copyWith({String? url}) {
    return Attachment(
      id: id,
      name: name,
      path: path,
      url: url ?? this.url,
      bytes: bytes,
    );
  }
}

