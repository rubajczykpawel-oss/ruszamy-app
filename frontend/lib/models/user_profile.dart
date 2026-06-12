class UserProfile {
  final int id;
  final String email;
  final String username;
  final String? city;
  final int? age;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.city,
    required this.age,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      city: json['city'],
      age: json['age'],
    );
  }
}