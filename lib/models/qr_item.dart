class QrItem {
  final int? id;
  final String content;
  final bool isUrl;
  final int createdAt;
  final String? label;

  const QrItem({
    this.id,
    required this.content,
    required this.isUrl,
    required this.createdAt,
    this.label,
  });

  factory QrItem.fromContent(String content, {String? label}) {
    final c = content.trim();
    final uri = Uri.tryParse(c);
    final isUrl =
        uri != null && (uri.isScheme('http') || uri.isScheme('https'));
    return QrItem(
      content: c,
      isUrl: isUrl,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      label: label,
    );
  }

  QrItem copyWith({int? id, String? label}) => QrItem(
    id: id ?? this.id,
    content: content,
    isUrl: isUrl,
    createdAt: createdAt,
    label: label ?? this.label,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'content': content,
    'is_url': isUrl ? 1 : 0,
    'created_at': createdAt,
    'label': label,
  };

  factory QrItem.fromMap(Map<String, dynamic> m) => QrItem(
    id: m['id'] as int?,
    content: m['content'] as String,
    isUrl: (m['is_url'] as int) == 1,
    createdAt: m['created_at'] as int,
    label: m['label'] as String?,
  );
}
