class FavoriteQuote {
  final int? id;
  final int userId;
  final int quoteId;
  final String quoteText;
  final String quoteAuthor;
  final DateTime createdAt;

  FavoriteQuote({
    this.id,
    required this.userId,
    required this.quoteId,
    required this.quoteText,
    required this.quoteAuthor,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'quote_id': quoteId,
      'quote_text': quoteText,
      'quote_author': quoteAuthor,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FavoriteQuote.fromMap(Map<String, dynamic> map) {
    return FavoriteQuote(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      quoteId: map['quote_id'] as int,
      quoteText: map['quote_text'] as String,
      quoteAuthor: map['quote_author'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
