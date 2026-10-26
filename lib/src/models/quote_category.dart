enum QuoteCategory {
  motivation('Motivation', '🔥', 'Fuel your ambition and drive'),
  wisdom('Wisdom', '💡', 'Timeless insights and life lessons'),
  happiness('Happiness', '😊', 'Joy and positive vibes'),
  success('Success', '🎯', 'Achievement and excellence'),
  courage('Courage', '💪', 'Strength and bravery'),
  love('Love', '❤️', 'Relationships and compassion'),
  philosophy('Philosophy', '🤔', 'Deep thoughts and meaning'),
  inspiration('Inspiration', '✨', 'Spark your creativity'),
  mindfulness('Mindfulness', '🧘', 'Peace and presence'),
  leadership('Leadership', '👑', 'Guide and influence'),
  perseverance('Perseverance', '🌟', 'Never give up'),
  creativity('Creativity', '🎨', 'Innovation and imagination'),
  knowledge('Knowledge', '📚', 'Learning and growth'),
  nature('Nature', '🌿', 'Connection with the world'),
  time('Time', '⏰', 'Value every moment');

  final String displayName;
  final String emoji;
  final String description;

  const QuoteCategory(this.displayName, this.emoji, this.description);

  String get label => '$emoji $displayName';
}

class QuoteCollection {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final List<int> quoteIds;
  final DateTime createdAt;
  final bool isUserCreated;

  const QuoteCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.quoteIds,
    required this.createdAt,
    this.isUserCreated = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'quote_ids': quoteIds.join(','),
      'created_at': createdAt.toIso8601String(),
      'is_user_created': isUserCreated ? 1 : 0,
    };
  }

  factory QuoteCollection.fromMap(Map<String, dynamic> map) {
    return QuoteCollection(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      quoteIds: (map['quote_ids'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
      isUserCreated: (map['is_user_created'] as int) == 1,
    );
  }

  QuoteCollection copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    List<int>? quoteIds,
    DateTime? createdAt,
    bool? isUserCreated,
  }) {
    return QuoteCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      quoteIds: quoteIds ?? this.quoteIds,
      createdAt: createdAt ?? this.createdAt,
      isUserCreated: isUserCreated ?? this.isUserCreated,
    );
  }
}
