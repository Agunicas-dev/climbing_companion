//Model class for user settings.

class Settings {
  String username;
  String bio;
  String location;
  String profilePicturePath; //file path for the profile picture
  bool likesBouldering;
  bool likesLead;
  String gradingSystem; //"hueco" or "font"
  bool useDisciplineGradeSystems;
  String units; //"metric" or "imperial"
  String language;
  String theme; //"system","light","dark"
  String fontSize;
  String seedColor; //hex color string for theme seed color
  bool notifications;

  //Constructor with default values for all fields.
  Settings({
    this.username = '',
    this.bio = '',
    this.location = '',
    this.profilePicturePath = '',
    this.likesBouldering = true,
    this.likesLead = true,
    this.gradingSystem = 'hueco',
    this.useDisciplineGradeSystems = false,
    this.units = 'metric',
    this.language = 'en',
    this.theme = 'system',
    this.fontSize = 'medium',
    this.seedColor = '#81D4FA',
    this.notifications = true,
  });


  //Convert the settings to a map for storage in SharedPreferences or Isar.
  Map<String, Object> toMap() {
    return {
      'username': username,
      'bio': bio,
      'location': location,
      'profilePicturePath': profilePicturePath,
      'likesBouldering': likesBouldering,
      'likesLead': likesLead,
      'gradingSystem': gradingSystem,
      'useDisciplineGradeSystems': useDisciplineGradeSystems,
      'units': units,
      'language': language,
      'theme': theme,
      'fontSize': fontSize,
      'seedColor': seedColor,
      'notifications': notifications,
    };
  }

  //Create a Settings object from a map retrieved from SharedPreferences or Isar.
  factory Settings.fromMap(Map<String, Object?> map) {
    return Settings(
      username: (map['username'] as String?) ?? '',
      bio: (map['bio'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      profilePicturePath: (map['profilePicturePath'] as String?) ?? '',
      likesBouldering: (map['likesBouldering'] as bool?) ?? true,
      likesLead: (map['likesLead'] as bool?) ?? true,
      gradingSystem: (map['gradingSystem'] as String?) ?? 'hueco',
      useDisciplineGradeSystems:
          (map['useDisciplineGradeSystems'] as bool?) ?? false,
      units: (map['units'] as String?) ?? 'metric',
      language: (map['language'] as String?) ?? 'en',
      theme: (map['theme'] as String?) ?? 'system',
      fontSize: (map['fontSize'] as String?) ?? 'medium',
      seedColor: (map['seedColor'] as String?) ?? '#81D4FA',
      notifications: (map['notifications'] as bool?) ?? true,
    );
  }
}
