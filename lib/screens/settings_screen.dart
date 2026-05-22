import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../main.dart';
import '../models/settings.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving image: $e')),
          );
        }
      }
    }
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
          child: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
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
          ? const Center(child: CircularProgressIndicator()) //If the page is still loading, show a circular progress indicator in the center of the screen.
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: _settings.profilePicturePath.isEmpty
                          ? Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.grey[600]),
                                  const SizedBox(height: 4),
                                  Text('Tap to upload', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(File(_settings.profilePicturePath)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
                  const SizedBox(height: 8),
                  TextField(controller: _bioCtrl, decoration: const InputDecoration(labelText: 'Bio')),
                  const SizedBox(height: 8),
                  TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
                  const SizedBox(height: 16),

                  const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.gradingSystem,
                    items: const [
                      DropdownMenuItem(value: 'YDS', child: Text('YDS')),
                      DropdownMenuItem(value: 'French', child: Text('French')),
                      DropdownMenuItem(value: 'Font', child: Text('Font')),
                    ],
                    onChanged: (v) => setState(() => _settings.gradingSystem = v ?? _settings.gradingSystem),
                    decoration: const InputDecoration(labelText: 'Grading system'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.units,
                    items: const [
                      DropdownMenuItem(value: 'metric', child: Text('Metric')),
                      DropdownMenuItem(value: 'imperial', child: Text('Imperial')),
                    ],
                    onChanged: (v) => setState(() => _settings.units = v ?? _settings.units),
                    decoration: const InputDecoration(labelText: 'Units'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    ],
                    onChanged: (v) => setState(() => _settings.language = v ?? _settings.language),
                    decoration: const InputDecoration(labelText: 'Language'),
                  ),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    value: _settings.notifications,
                    onChanged: (v) => setState(() => _settings.notifications = v),
                  ),
                  const SizedBox(height: 16),

                  const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _settings.theme,
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (v) => setState(() => _settings.theme = v ?? _settings.theme),
                    decoration: const InputDecoration(labelText: 'Theme'),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickSeedColor,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Theme Color', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 2),
                              Text(_settings.seedColor, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: ThemeService.seedColorFromHex(_settings.seedColor),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
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
                    onChanged: (v) => setState(() => _settings.fontSize = v ?? _settings.fontSize),
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