class HomeItem {
  final String title;
  final String description;
  final DateTime createdAt;

  const HomeItem({
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
