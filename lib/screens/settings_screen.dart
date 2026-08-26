import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              _SectionHeader(title: 'Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: themeProvider.toggleDarkMode,
              ),
              const Divider(),
              _SectionHeader(title: 'Notifications'),
              SwitchListTile(
                title: const Text('Sound'),
                subtitle: const Text('Play sound when timer ends'),
                value: themeProvider.soundEnabled,
                onChanged: (value) => themeProvider.setSoundEnabled(value),
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate when timer ends'),
                value: themeProvider.vibrationEnabled,
                onChanged: (value) => themeProvider.setVibrationEnabled(value),
              ),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Show notification when timer ends'),
                value: themeProvider.notificationsEnabled,
                onChanged: (value) =>
                    themeProvider.setNotificationsEnabled(value),
              ),
              const Divider(),
              _SectionHeader(title: 'Display'),
              SwitchListTile(
                title: const Text('Keep Screen On'),
                subtitle: const Text('Prevent screen from turning off'),
                value: themeProvider.keepScreenOn,
                onChanged: (value) => themeProvider.setKeepScreenOn(value),
              ),
              const Divider(),
              _SectionHeader(title: 'Data'),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Import/Export'),
                subtitle: const Text('Share your timers and groups'),
                onTap: () => _showImportExportDialog(context),
              ),
              const Divider(),
              _SectionHeader(title: 'About'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.6'),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Multi Timer App'),
                subtitle: const Text('Manage multiple timers with ease'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImportExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import / Export'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Export All Data'),
              subtitle: const Text('Copy all timers and groups'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Data'),
              subtitle: const Text('Paste shared data to import'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import feature coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
