import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/device_status_widget.dart';
import './widgets/settings_row_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/theme_selector_widget.dart';
import './widgets/voice_sensitivity_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Settings state variables
  bool _biometricAuth = true;
  bool _commandConfirmation = false;
  bool _commandAlerts = true;
  bool _connectionAlerts = true;
  bool _failedCommandAlerts = true;
  bool _hapticFeedback = true;
  bool _soundEffects = true;
  String _currentTheme = 'light';
  String _voiceLanguage = 'English (US)';
  String _wakeWord = 'Hey Assistant';
  String _autoLockTimeout = '5 minutes';
  double _voiceSensitivity = 0.7;

  // Mock connected devices data
  final List<Map<String, dynamic>> _connectedDevices = [
    {
      'name': 'MacBook Pro - Work',
      'isOnline': true,
      'lastSeen': '',
    },
    {
      'name': 'Windows Desktop - Home',
      'isOnline': false,
      'lastSeen': '2 hours ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricAuth = prefs.getBool('biometric_auth') ?? true;
      _commandConfirmation = prefs.getBool('command_confirmation') ?? false;
      _commandAlerts = prefs.getBool('command_alerts') ?? true;
      _connectionAlerts = prefs.getBool('connection_alerts') ?? true;
      _failedCommandAlerts = prefs.getBool('failed_command_alerts') ?? true;
      _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
      _soundEffects = prefs.getBool('sound_effects') ?? true;
      _currentTheme = prefs.getString('theme') ?? 'light';
      _voiceLanguage = prefs.getString('voice_language') ?? 'English (US)';
      _wakeWord = prefs.getString('wake_word') ?? 'Hey Assistant';
      _autoLockTimeout = prefs.getString('auto_lock_timeout') ?? '5 minutes';
      _voiceSensitivity = prefs.getDouble('voice_sensitivity') ?? 0.7;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  void _showLanguageSelector() {
    final languages = [
      'English (US)',
      'English (UK)',
      'Spanish',
      'French',
      'German',
      'Italian',
      'Portuguese',
      'Japanese',
      'Korean',
      'Chinese (Mandarin)',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Language',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...languages.map((language) {
                final isSelected = _voiceLanguage == language;
                return ListTile(
                  title: Text(language),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _voiceLanguage = language;
                    });
                    _saveSetting('voice_language', language);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showWakeWordSelector() {
    final wakeWords = [
      'Hey Assistant',
      'OK Assistant',
      'Computer',
      'Assistant',
      'Hello Assistant',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wake Word',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...wakeWords.map((word) {
                final isSelected = _wakeWord == word;
                return ListTile(
                  title: Text(word),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _wakeWord = word;
                    });
                    _saveSetting('wake_word', word);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showAutoLockSelector() {
    final timeouts = [
      'Never',
      '1 minute',
      '5 minutes',
      '15 minutes',
      '30 minutes',
      '1 hour',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auto-lock Timeout',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              ...timeouts.map((timeout) {
                final isSelected = _autoLockTimeout == timeout;
                return ListTile(
                  title: Text(timeout),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _autoLockTimeout = timeout;
                    });
                    _saveSetting('auto_lock_timeout', timeout);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset App'),
          content: Text(
            'This will clear all app data including connected devices, settings, and command history. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('App data has been reset'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
                // Reset to default values
                _loadSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Connected Devices Section
                SettingsSectionWidget(
                  title: 'Connected Devices',
                  children: [
                    ..._connectedDevices.map((device) {
                      return DeviceStatusWidget(
                        deviceName: device['name'] as String,
                        isOnline: device['isOnline'] as bool,
                        lastSeen: device['lastSeen'] as String,
                      );
                    }).toList(),
                    SettingsRowWidget(
                      title: 'Manage Connections',
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, '/desktop-connection-setup');
                      },
                      showDivider: false,
                    ),
                  ],
                ),

                // Voice Settings Section
                SettingsSectionWidget(
                  title: 'Voice Settings',
                  children: [
                    SettingsRowWidget(
                      title: 'Voice Language',
                      subtitle: _voiceLanguage,
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: _showLanguageSelector,
                    ),
                    SettingsRowWidget(
                      title: 'Wake Word',
                      subtitle: _wakeWord,
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: _showWakeWordSelector,
                    ),
                    VoiceSensitivityWidget(
                      initialValue: _voiceSensitivity,
                      onChanged: (value) {
                        setState(() {
                          _voiceSensitivity = value;
                        });
                        _saveSetting('voice_sensitivity', value);
                      },
                    ),
                  ],
                ),

                // Security Section
                SettingsSectionWidget(
                  title: 'Security',
                  children: [
                    SettingsRowWidget(
                      title: 'Biometric Authentication',
                      subtitle: 'Use fingerprint or face recognition',
                      trailing: Switch(
                        value: _biometricAuth,
                        onChanged: (value) {
                          setState(() {
                            _biometricAuth = value;
                          });
                          _saveSetting('biometric_auth', value);
                        },
                      ),
                    ),
                    SettingsRowWidget(
                      title: 'Auto-lock Timeout',
                      subtitle: _autoLockTimeout,
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: _showAutoLockSelector,
                    ),
                    SettingsRowWidget(
                      title: 'Command Confirmation',
                      subtitle: 'Confirm sensitive operations',
                      trailing: Switch(
                        value: _commandConfirmation,
                        onChanged: (value) {
                          setState(() {
                            _commandConfirmation = value;
                          });
                          _saveSetting('command_confirmation', value);
                        },
                      ),
                      showDivider: false,
                    ),
                  ],
                ),

                // Notifications Section
                SettingsSectionWidget(
                  title: 'Notifications',
                  children: [
                    SettingsRowWidget(
                      title: 'Command Completion Alerts',
                      trailing: Switch(
                        value: _commandAlerts,
                        onChanged: (value) {
                          setState(() {
                            _commandAlerts = value;
                          });
                          _saveSetting('command_alerts', value);
                        },
                      ),
                    ),
                    SettingsRowWidget(
                      title: 'Connection Status Changes',
                      trailing: Switch(
                        value: _connectionAlerts,
                        onChanged: (value) {
                          setState(() {
                            _connectionAlerts = value;
                          });
                          _saveSetting('connection_alerts', value);
                        },
                      ),
                    ),
                    SettingsRowWidget(
                      title: 'Failed Command Notifications',
                      trailing: Switch(
                        value: _failedCommandAlerts,
                        onChanged: (value) {
                          setState(() {
                            _failedCommandAlerts = value;
                          });
                          _saveSetting('failed_command_alerts', value);
                        },
                      ),
                      showDivider: false,
                    ),
                  ],
                ),

                // App Preferences Section
                SettingsSectionWidget(
                  title: 'App Preferences',
                  children: [
                    ThemeSelectorWidget(
                      currentTheme: _currentTheme,
                      onThemeChanged: (theme) {
                        setState(() {
                          _currentTheme = theme;
                        });
                        _saveSetting('theme', theme);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppTheme.lightTheme.dividerColor,
                      indent: 4.w,
                      endIndent: 4.w,
                    ),
                    SettingsRowWidget(
                      title: 'Haptic Feedback',
                      trailing: Switch(
                        value: _hapticFeedback,
                        onChanged: (value) {
                          setState(() {
                            _hapticFeedback = value;
                          });
                          _saveSetting('haptic_feedback', value);
                        },
                      ),
                    ),
                    SettingsRowWidget(
                      title: 'Sound Effects',
                      trailing: Switch(
                        value: _soundEffects,
                        onChanged: (value) {
                          setState(() {
                            _soundEffects = value;
                          });
                          _saveSetting('sound_effects', value);
                        },
                      ),
                      showDivider: false,
                    ),
                  ],
                ),

                // About Section
                SettingsSectionWidget(
                  title: 'About',
                  children: [
                    SettingsRowWidget(
                      title: 'App Version',
                      subtitle: '1.0.0 (Build 1)',
                      showDivider: true,
                    ),
                    SettingsRowWidget(
                      title: 'Privacy Policy',
                      trailing: CustomIconWidget(
                        iconName: 'open_in_new',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () {
                        // Open privacy policy URL
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening Privacy Policy...')),
                        );
                      },
                    ),
                    SettingsRowWidget(
                      title: 'Terms of Service',
                      trailing: CustomIconWidget(
                        iconName: 'open_in_new',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () {
                        // Open terms of service URL
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Opening Terms of Service...')),
                        );
                      },
                    ),
                    SettingsRowWidget(
                      title: 'Contact Support',
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () {
                        // Open support contact
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening Support Contact...')),
                        );
                      },
                      showDivider: false,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Reset App Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ElevatedButton(
                    onPressed: _showResetConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reset App',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
