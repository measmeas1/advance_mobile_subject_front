class Category {
  final int id;
  final String name;
  final String? description;
  final String? slug;
  final int? parentId;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.slug,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      slug: json['slug'],
      parentId: json['parent_id'],
    );
  }
}