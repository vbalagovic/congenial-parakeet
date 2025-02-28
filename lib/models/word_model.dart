class Word {
  final String id;
  final String text;
  final String userId;
  final DateTime createdAt;

  Word({
    required this.id,
    required this.text,
    required this.userId,
    required this.createdAt,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
