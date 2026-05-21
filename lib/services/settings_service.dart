import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsService {
  static const _keyUsername = 'settings_username';
  static const _keyBio = 'settings_bio';
  static const _keyLocation = 'settings_location';
  static const _keyProfilePicture = 'settings_profile_picture';
  static const _keyGrading = 'settings_grading';
  static const _keyUnits = 'settings_units';
  static const _keyLanguage = 'settings_language';
  static const _keyNotifications = 'settings_notifications';
  static const _keyTheme = 'settings_theme';
  static const _keyFontSize = 'settings_font_size';

  static Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return Settings(
      username: prefs.getString(_keyUsername) ?? '',
      bio: prefs.getString(_keyBio) ?? '',
      location: prefs.getString(_keyLocation) ?? '',
      profilePicturePath: prefs.getString(_keyProfilePicture) ?? '',
      gradingSystem: prefs.getString(_keyGrading) ?? 'YDS',
      units: prefs.getString(_keyUnits) ?? 'metric',
      language: prefs.getString(_keyLanguage) ?? 'en',
      notifications: prefs.getBool(_keyNotifications) ?? true,
      theme: prefs.getString(_keyTheme) ?? 'system',
      fontSize: prefs.getString(_keyFontSize) ?? 'medium',
    );
  }

  static Future<void> saveSettings(Settings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, s.username);
    await prefs.setString(_keyBio, s.bio);
    await prefs.setString(_keyLocation, s.location);
    await prefs.setString(_keyProfilePicture, s.profilePicturePath);
    await prefs.setString(_keyGrading, s.gradingSystem);
    await prefs.setString(_keyUnits, s.units);
    await prefs.setString(_keyLanguage, s.language);
    await prefs.setBool(_keyNotifications, s.notifications);
    await prefs.setString(_keyTheme, s.theme);
    await prefs.setString(_keyFontSize, s.fontSize);
  }
}
