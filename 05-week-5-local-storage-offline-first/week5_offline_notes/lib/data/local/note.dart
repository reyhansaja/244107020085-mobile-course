class Note {
  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    required this.dirty,
  });

  factory Note.fromMap(Map<String, Object?> map) => Note(
        id: map['id'] as int?,
        title: map['title'] as String,
        body: map['body'] as String,
        updatedAt: DateTime.parse(map['updated_at'] as String),
        dirty: (map['dirty'] as int) == 1,
      );

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'body': body,
        'updated_at': updatedAt.toIso8601String(),
        'dirty': dirty ? 1 : 0,
      };
}
