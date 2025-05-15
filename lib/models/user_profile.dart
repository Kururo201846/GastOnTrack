class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String country;
  final DateTime? createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.country,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'country': country,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      country: map['country'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }
}