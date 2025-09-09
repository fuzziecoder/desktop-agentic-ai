import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/command_input_field.dart';
import './widgets/command_status_card.dart';
import './widgets/command_suggestions.dart';
import './widgets/connection_status_bar.dart';
import './widgets/recent_commands_list.dart';
import './widgets/transcription_display.dart';
import './widgets/voice_input_button.dart';

class CommandInterface extends StatefulWidget {
  const CommandInterface({Key? key}) : super(key: key);

  @override
  State<CommandInterface> createState() => _CommandInterfaceState();
}

class _CommandInterfaceState extends State<CommandInterface>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commandController = TextEditingController();

  // Voice recording state
  bool _isRecording = false;
  String _transcription = '';
  double _confidence = 0.0;
  bool _showTranscription = false;

  // Connection state
  bool _isConnected = true;
  String _systemName = 'DESKTOP-WORKSTATION';

  // Command status
  CommandStatus _commandStatus = CommandStatus.idle;
  String _statusMessage = '';
  bool _showStatus = false;

  // Command history
  final List<Map<String, dynamic>> _recentCommands = [
    {
      'command': 'Open Documents folder',
      'status': 'Completed',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'result': 'Documents folder opened successfully',
    },
    {
      'command': 'Launch Google Chrome',
      'status': 'Completed',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'result': 'Chrome launched with 3 tabs restored',
    },
    {
      'command': 'Search web for Flutter tutorials',
      'status': 'Completed',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'result': 'Search results opened in default browser',
    },
    {
      'command': 'Open VS Code workspace',
      'status': 'Failed',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'result': 'Workspace file not found',
    },
    {
      'command': 'System information',
      'status': 'Completed',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'result': 'Windows 11 Pro, 16GB RAM, Intel i7-12700K',
    },
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _commandController.addListener(_onTextChanged);
    _simulateConnection();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _simulateConnection() {
    // Simulate connection status changes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _systemName = 'DESKTOP-WORKSTATION';
        });
      }
    });
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _transcription = '';
      _confidence = 0.0;
      _showTranscription = true;
    });

    // Simulate real-time transcription
    _simulateTranscription();
  }

  void _stopVoiceRecording() {
    setState(() {
      _isRecording = false;
      _showTranscription = false;
    });

    if (_transcription.isNotEmpty) {
      _commandController.text = _transcription;
      _executeCommand(_transcription);
    }
  }

  void _simulateTranscription() {
    if (!_isRecording) return;

    final phrases = [
      'Open',
      'Open Documents',
      'Open Documents folder',
    ];

    int currentIndex = 0;

    void updateTranscription() {
      if (!_isRecording || currentIndex >= phrases.length) return;

      setState(() {
        _transcription = phrases[currentIndex];
        _confidence = 0.6 + (currentIndex * 0.15);
      });

      currentIndex++;

      if (currentIndex < phrases.length) {
        Future.delayed(const Duration(milliseconds: 800), updateTranscription);
      }
    }

    Future.delayed(const Duration(milliseconds: 500), updateTranscription);
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty || !_isConnected) return;

    setState(() {
      _commandStatus = CommandStatus.executing;
      _statusMessage = 'Processing command: "$command"';
      _showStatus = true;
    });

    // Simulate command execution
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final success = command.toLowerCase().contains('error') ? false : true;

        setState(() {
          _commandStatus =
              success ? CommandStatus.completed : CommandStatus.error;
          _statusMessage = success
              ? 'Command executed successfully'
              : 'Failed to execute command. Please try again.';
        });

        // Add to history
        _recentCommands.insert(0, {
          'command': command,
          'status': success ? 'Completed' : 'Failed',
          'timestamp': DateTime.now(),
          'result': success
              ? 'Command executed on $_systemName'
              : 'Command execution failed',
        });

        // Clear input
        _commandController.clear();

        // Hide status after delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showStatus = false;
            });
          }
        });
      }
    });
  }

  void _onSuggestionTapped(String suggestion) {
    _commandController.text = suggestion;
    _executeCommand(suggestion);
  }

  void _onRepeatCommand(String command) {
    _commandController.text = command;
  }

  void _onDeleteCommand(int index) {
    setState(() {
      _recentCommands.removeAt(index);
    });
  }

  void _onRefresh() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onConnectionTap() {
    Navigator.pushNamed(context, '/desktop-connection-setup');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supported Commands',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection('File Operations', [
                'Open [folder name]',
                'Open Documents',
                'Open Downloads',
                'Navigate to [path]',
              ]),
              SizedBox(height: 2.h),
              _buildHelpSection('Applications', [
                'Launch [app name]',
                'Open Chrome',
                'Start VS Code',
                'Run Calculator',
              ]),
              SizedBox(height: 2.h),
              _buildHelpSection('Web Search', [
                'Search for [query]',
                'Google [search term]',
                'Look up [information]',
              ]),
              SizedBox(height: 2.h),
              _buildHelpSection('System', [
                'System information',
                'Check disk space',
                'Show running processes',
                'Exit assistant',
              ]),
            ],
          ),
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

  Widget _buildHelpSection(String title, List<String> commands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        ...commands.map((command) => Padding(
              padding: EdgeInsets.only(left: 2.w, bottom: 0.5.h),
              child: Text(
                '• $command',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter Assistant',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: Column(
            children: [
              ConnectionStatusBar(
                isConnected: _isConnected,
                systemName: _systemName,
                onConnectionTap: _onConnectionTap,
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Command'),
                  Tab(text: 'History'),
                  Tab(text: 'Settings'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommandTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showHelpDialog,
              child: CustomIconWidget(
                iconName: 'help',
                color: Colors.white,
                size: 6.w,
              ),
            )
          : null,
    );
  }

  Widget _buildCommandTab() {
    return Column(
      children: [
        // Command suggestions
        CommandSuggestions(
          onSuggestionTapped: _onSuggestionTapped,
          isEnabled: _isConnected,
        ),

        // Transcription display
        TranscriptionDisplay(
          transcription: _transcription,
          confidence: _confidence,
          isVisible: _showTranscription,
        ),

        // Command input field
        CommandInputField(
          controller: _commandController,
          onMicPressed:
              _isRecording ? _stopVoiceRecording : _startVoiceRecording,
          onSendPressed: () => _executeCommand(_commandController.text),
          isEnabled: _isConnected,
          hasText: _commandController.text.trim().isNotEmpty,
        ),

        // Command status card
        CommandStatusCard(
          status: _commandStatus,
          message: _statusMessage,
          isVisible: _showStatus,
          onRetry: _commandStatus == CommandStatus.error
              ? () => _executeCommand(_commandController.text)
              : null,
        ),

        // Voice input button
        Container(
          margin: EdgeInsets.symmetric(vertical: 2.h),
          child: VoiceInputButton(
            isRecording: _isRecording,
            onPressed:
                _isRecording ? _stopVoiceRecording : _startVoiceRecording,
            isConnected: _isConnected,
          ),
        ),

        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return RecentCommandsList(
      commands: _recentCommands,
      onRepeatCommand: _onRepeatCommand,
      onDeleteCommand: _onDeleteCommand,
      onRefresh: _onRefresh,
      isLoading: _isLoading,
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Settings',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'computer',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Desktop Connection'),
              subtitle: Text(_isConnected ? 'Connected' : 'Disconnected'),
              trailing: Switch(
                value: _isConnected,
                onChanged: (value) {
                  setState(() {
                    _isConnected = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'settings_ethernet',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Connection Setup'),
              subtitle: const Text('Configure desktop pairing'),
              trailing: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              onTap: _onConnectionTap,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Voice Settings',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'mic',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Voice Recognition'),
              subtitle: const Text('Enable voice commands'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'volume_up',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Audio Feedback'),
              subtitle: const Text('Play sounds for confirmations'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Security',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'fingerprint',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Secure sensitive commands'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Command Confirmation'),
              subtitle: const Text('Confirm sensitive operations'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'About',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0 (Build 1)'),
            ),
          ),
          SizedBox(height: 1.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'privacy_tip',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Privacy Policy'),
              trailing: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
