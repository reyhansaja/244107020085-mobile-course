import '../../domain/entities/announcement.dart';

/// Model = representasi data luar (JSON) + mapping. `toMap`/`fromMap` hanya
/// hidup di sini, entity tetap bersih.
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.publishedAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(map['published_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'published_at': publishedAt.toIso8601String(),
  };

  Announcement toEntity() =>
      Announcement(id: id, title: title, body: body, publishedAt: publishedAt);
}
