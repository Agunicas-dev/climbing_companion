import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';
import 'grade_scale_service.dart';

/*Service in charge of loading and saving the user settings using SharedPreferences.
It provides two static methods: loadSettings and saveSettings, which handle the retrieval and storage of the settings data, respectively.*/

class SettingsService {
  //Keys for SharedPreferences storage.
  static const _keyUsername = 'settings_username';
  static const _keyBio = 'settings_bio';
  static const _keyLocation = 'settings_location';
  static const _keyProfilePicture = 'settings_profile_picture';
  static const _keyLikesBouldering = 'settings_likes_bouldering';
  static const _keyLikesLead = 'settings_likes_lead';
  static const _keyGrading = 'settings_grading';
  static const _keyUseDisciplineGradeSystems =
      'settings_use_discipline_grade_systems';
  static const _keyUnits = 'settings_units';
  static const _keyLanguage = 'settings_language';
  static const _keyNotifications = 'settings_notifications';
  static const _keyTheme = 'settings_theme';
  static const _keyFontSize = 'settings_font_size';
  static const _keySeedColor = 'settings_seed_color';

  
  //Function to load the settings from SharedPreferences, returning a Settings object with the retrieved values or default values if not set.
  static Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return Settings(
      username: prefs.getString(_keyUsername) ?? '',
      bio: prefs.getString(_keyBio) ?? '',
      location: prefs.getString(_keyLocation) ?? '',
      profilePicturePath: prefs.getString(_keyProfilePicture) ?? '',
      likesBouldering: prefs.getBool(_keyLikesBouldering) ?? true,
      likesLead: prefs.getBool(_keyLikesLead) ?? true,
      gradingSystem: GradeScaleService.normalizeSystem(
        prefs.getString(_keyGrading) ?? GradeScaleService.hueco,
      ),
      useDisciplineGradeSystems:
          prefs.getBool(_keyUseDisciplineGradeSystems) ?? false,
      units: prefs.getString(_keyUnits) ?? 'metric',
      language: prefs.getString(_keyLanguage) ?? 'en',
      notifications: prefs.getBool(_keyNotifications) ?? true,
      theme: prefs.getString(_keyTheme) ?? 'system',
      fontSize: prefs.getString(_keyFontSize) ?? 'medium',
      seedColor: prefs.getString(_keySeedColor) ?? '#81D4FA',
    );
  }


  //Function to save the settings to SharedPreferences, taking a Settings object as input and storing its values using the defined keys.
  static Future<void> saveSettings(Settings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, s.username);
    await prefs.setString(_keyBio, s.bio);
    await prefs.setString(_keyLocation, s.location);
    await prefs.setString(_keyProfilePicture, s.profilePicturePath);
    await prefs.setBool(_keyLikesBouldering, s.likesBouldering);
    await prefs.setBool(_keyLikesLead, s.likesLead);
    await prefs.setString(
      _keyGrading,
      GradeScaleService.normalizeSystem(s.gradingSystem),
    );
    await prefs.setBool(
      _keyUseDisciplineGradeSystems,
      s.useDisciplineGradeSystems,
    );
    await prefs.setString(_keyUnits, s.units);
    await prefs.setString(_keyLanguage, s.language);
    await prefs.setBool(_keyNotifications, s.notifications);
    await prefs.setString(_keyTheme, s.theme);
    await prefs.setString(_keyFontSize, s.fontSize);
    await prefs.setString(_keySeedColor, s.seedColor);
  }
}
