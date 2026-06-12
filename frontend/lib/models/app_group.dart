class AppGroup {
  final int id;
  final String name;
  final String description;
  final String city;
  final String activityType;
  final int ownerId;
  final String createdAt;

  AppGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.activityType,
    required this.ownerId,
    required this.createdAt,
  });

  factory AppGroup.fromJson(Map<String, dynamic> json) {
    return AppGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      activityType: json['activity_type'],
      ownerId: json['owner_id'],
      createdAt: json['created_at'],
    );
  }
}