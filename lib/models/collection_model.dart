import 'dart:convert';

class Collection {
  final String id;
  final String name;
  final String emoji;
  final List<String> promptIds;

  Collection({
    required this.id,
    required this.name,
    this.emoji = '📁',
    List<String>? promptIds,
  }) : promptIds = promptIds ?? [];

  Collection copyWith({
    String? name,
    String? emoji,
    List<String>? promptIds,
  }) =>
      Collection(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        promptIds: promptIds ?? List.from(this.promptIds),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'promptIds': promptIds,
      };

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '📁',
        promptIds: List<String>.from(json['promptIds'] as List? ?? []),
      );

  static String encodeList(List<Collection> collections) =>
      jsonEncode(collections.map((c) => c.toJson()).toList());

  static List<Collection> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list.map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
  }
}
