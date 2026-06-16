import 'user_profile.dart';

class GroupMember {
  final int id;
  final int groupId;
  final int userId;
  final String role;
  final String joinedAt;
  final UserProfile user;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.user,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      role: json['role'],
      joinedAt: json['joined_at'],
      user: UserProfile.fromJson(json['user']),
    );
  }
}