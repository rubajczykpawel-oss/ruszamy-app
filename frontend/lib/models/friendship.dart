import 'user_profile.dart';

class Friendship {
  final int id;
  final int requesterId;
  final int receiverId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final UserProfile? requester;
  final UserProfile? receiver;

  Friendship({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.requester,
    required this.receiver,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'],
      requesterId: json['requester_id'],
      receiverId: json['receiver_id'],
      status: json['status'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      requester: json['requester'] == null
          ? null
          : UserProfile.fromJson(json['requester']),
      receiver: json['receiver'] == null
          ? null
          : UserProfile.fromJson(json['receiver']),
    );
  }
}