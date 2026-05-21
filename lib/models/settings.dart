class Settings {
  String username;
  String bio;
  String location;
  String profilePicturePath; // local file path to profile picture
  String gradingSystem; // e.g., 'YDS', 'Font'
  String units; // 'metric' or 'imperial'
  String language; // e.g., 'en', 'es'
  bool notifications;
  String theme; // 'system','light','dark'
  String fontSize; // 'small','medium','large'

  Settings({
    this.username = '',
    this.bio = '',
    this.location = '',
    this.profilePicturePath = '',
    this.gradingSystem = 'YDS',
    this.units = 'metric',
    this.language = 'en',
    this.notifications = true,
    this.theme = 'system',
    this.fontSize = 'medium',
  });

  Map<String, Object> toMap() {
    return {
      'username': username,
      'bio': bio,
      'location': location,
      'profilePicturePath': profilePicturePath,
      'gradingSystem': gradingSystem,
      'units': units,
      'language': language,
      'notifications': notifications,
      'theme': theme,
      'fontSize': fontSize,
    };
  }

  factory Settings.fromMap(Map<String, Object?> map) {
    return Settings(
      username: (map['username'] as String?) ?? '',
      bio: (map['bio'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      profilePicturePath: (map['profilePicturePath'] as String?) ?? '',
      gradingSystem: (map['gradingSystem'] as String?) ?? 'YDS',
      units: (map['units'] as String?) ?? 'metric',
      language: (map['language'] as String?) ?? 'en',
      notifications: (map['notifications'] as bool?) ?? true,
      theme: (map['theme'] as String?) ?? 'system',
      fontSize: (map['fontSize'] as String?) ?? 'medium',
    );
  }
}
