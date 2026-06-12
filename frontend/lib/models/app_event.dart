class AppEvent {
  final int id;
  final String title;
  final String description;
  final String activityType;
  final String city;
  final String locationName;
  final String date;
  final String time;
  final int maxParticipants;
  final int participantsCount;
  final String level;
  final int? ageMin;
  final int? ageMax;
  final bool isPublic;
  final int creatorId;
  final int? groupId;

  AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.activityType,
    required this.city,
    required this.locationName,
    required this.date,
    required this.time,
    required this.maxParticipants,
    required this.participantsCount,
    required this.level,
    required this.ageMin,
    required this.ageMax,
    required this.isPublic,
    required this.creatorId,
    required this.groupId,
  });

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      activityType: json['activity_type'],
      city: json['city'],
      locationName: json['location_name'],
      date: json['date'],
      time: json['time'],
      maxParticipants: json['max_participants'],
      participantsCount: json['participants_count'] ?? 0,
      level: json['level'],
      ageMin: json['age_min'],
      ageMax: json['age_max'],
      isPublic: json['is_public'],
      creatorId: json['creator_id'],
      groupId: json['group_id'],
    );
  }
}