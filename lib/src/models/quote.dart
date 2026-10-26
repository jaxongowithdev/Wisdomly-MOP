class Quote {
  final int id;
  final String text;
  final String author;
  final String? source;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    this.source,
  });
}
