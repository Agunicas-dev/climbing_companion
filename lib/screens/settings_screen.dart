import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../main.dart';
import '../models/settings.dart';
import '../services/grade_scale_service.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Settings _settings;
  bool _loading = true;

  //Controllers for the text fields
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  //Load settings on app start and populate controllers with existing values.
  @override
  void initState() {
    super.initState();
    _load();
  }

  //Function to load settings from storage and update the UI accordingly.
  Future<void> _load() async {
    final s = await SettingsService.loadSettings();
    setState(() {
      _settings = s;
      _usernameCtrl.text = s.username;
      _bioCtrl.text = s.bio;
      _locationCtrl.text = s.location;
      _loading = false;
    });
  }

  //Function to save settings to storage and update the app's theme, font size, and theme color based on user preferences.
  Future<void> _save() async {
    setState(() {
      _loading = true;
    });
    _settings.username = _usernameCtrl.text;
    _settings.bio = _bioCtrl.text;
    _settings.location = _locationCtrl.text;
    await SettingsService.saveSettings(_settings);

    // Notify theme, font size, and seed color changes
    themeNotifier.value = _settings.theme;
    fontSizeNotifier.value = _settings.fontSize;
    seedColorNotifier.value = _settings.seedColor;

    setState(() {
      _loading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  //Function to open a color picker dialog and allow the user to select a new theme color.
  Future<void> _pickSeedColor() async {
    Color selectedColor = ThemeService.seedColorFromHex(_settings.seedColor);

    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        // Use AlertDialog to show the color picker
        return AlertDialog(
          title: const Text('Choose theme color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
              labelTypes: [ColorLabelType.hex],
              enableAlpha: false,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(selectedColor),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    // If a color was picked, update the settings with the new color in hex format.
    if (picked != null) {
      setState(() {
        _settings.seedColor = ThemeService.colorToHex(picked);
      });
    }
  }

  //Function to allow the user to pick an image from their gallery and save it as their profile picture in the app's documents directory.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        // Get app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/assets/images');

        // Create directory if it doesn't exist
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        // Copy image to app documents directory
        final profileImagePath = '${imagesDir.path}/profilePicture';
        final sourceFile = File(image.path);
        await sourceFile.copy(profileImagePath);

        //Update settings with new profile picture path and show success message.
        setState(() {
          _settings.profilePicturePath = profileImagePath;
        });

        //Show a success message to the user after successfully saving the profile picture.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } catch (e) {
        //Show an error message to the user if there was an issue saving the profile picture.
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
        }
      }
    }
  }

  void _deleteProfilePicture() {
    setState(() {
      _settings.profilePicturePath = '';
    });
  }

  Brightness _previewBrightness() {
    return switch (_settings.theme) {
      'light' => Brightness.light,
      'dark' => Brightness.dark,
      _ => Theme.of(context).brightness,
    };
  }

  String _profileImagePath() {
    if (_settings.profilePicturePath.isNotEmpty) {
      return _settings.profilePicturePath;
    }

    final suffix = _previewBrightness() == Brightness.dark ? 'dark' : 'light';
    return 'lib/assets/images/default_profile_$suffix.png';
  }

  ImageProvider _profileImage(String imagePath) {
    if (_settings.profilePicturePath.isNotEmpty) {
      return FileImage(File(imagePath));
    }

    return AssetImage(imagePath);
  }

  //Dispose of the text controllers when the widget is removed from the widget tree to free up resources and prevent memory leaks.
  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        shadowColor: Colors.black,
        elevation: 3,
      ),

      //Call to the _loading variable to determine whether to show a loading indicator or the settings form.
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            ) //If the page is still loading, show a circular progress indicator in the center of the screen.
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            final imagePath = _profileImagePath();
                            return GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                key: ValueKey(imagePath),
                                radius: 50,
                                backgroundImage: _profileImage(imagePath),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_camera),
                              label: const Text('Change'),
                            ),
                            if (_settings.profilePicturePath.isNotEmpty)
                              TextButton.icon(
                                onPressed: _deleteProfilePicture,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioCtrl,
                    decoration: const InputDecoration(labelText: 'Bio'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _PreferenceToggleButton(
                          icon: Icons.terrain,
                          label: 'Bouldering',
                          selected: _settings.likesBouldering,
                          onPressed: () => setState(
                            () => _settings.likesBouldering =
                                !_settings.likesBouldering,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PreferenceToggleButton(
                          icon: Icons.vertical_align_top,
                          label: 'Lead',
                          selected: _settings.likesLead,
                          onPressed: () => setState(
                            () => _settings.likesLead = !_settings.likesLead,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: GradeScaleService.normalizeSystem(
                      _settings.gradingSystem,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: GradeScaleService.hueco,
                        child: Text('Hueco (V-Scale)'),
                      ),
                      DropdownMenuItem(
                        value: GradeScaleService.font,
                        child: Text('Font'),
                      ),
                    ],
                    onChanged: _settings.useDisciplineGradeSystems
                        ? null
                        : (v) => setState(
                            () => _settings.gradingSystem =
                                v ?? _settings.gradingSystem,
                          ),
                    decoration: const InputDecoration(
                      labelText: 'Grading system',
                    ),
                    disabledHint: Text(
                      GradeScaleService.labelForSystem(_settings.gradingSystem),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Use discipline grade systems'),
                    subtitle: const Text('Hueco for bouldering, Font for lead'),
                    value: _settings.useDisciplineGradeSystems,
                    onChanged: (v) =>
                        setState(() => _settings.useDisciplineGradeSystems = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    ],
                    onChanged: (v) => setState(
                      () => _settings.language = v ?? _settings.language,
                    ),
                    decoration: const InputDecoration(labelText: 'Language'),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Appearance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.theme,
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (v) =>
                        setState(() => _settings.theme = v ?? _settings.theme),
                    decoration: const InputDecoration(labelText: 'Theme'),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickSeedColor,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: ThemeService.seedColorFromHex(
                                _settings.seedColor,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theme Color',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _settings.seedColor,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.fontSize,
                    items: const [
                      DropdownMenuItem(value: 'small', child: Text('Small')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'large', child: Text('Large')),
                    ],
                    onChanged: (v) => setState(
                      () => _settings.fontSize = v ?? _settings.fontSize,
                    ),
                    decoration: const InputDecoration(labelText: 'Font size'),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _PreferenceToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _PreferenceToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final backgroundColor = selected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: 48,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(
          selected ? Icons.check_circle : icon,
          color: foregroundColor,
        ),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
