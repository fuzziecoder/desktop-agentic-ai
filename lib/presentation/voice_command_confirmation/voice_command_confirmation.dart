import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './widgets/action_buttons.dart';
import './widgets/command_details_card.dart';
import './widgets/dont_ask_checkbox.dart';
import './widgets/voice_response_listener.dart';

class VoiceCommandConfirmation extends StatefulWidget {
  const VoiceCommandConfirmation({Key? key}) : super(key: key);

  @override
  State<VoiceCommandConfirmation> createState() =>
      _VoiceCommandConfirmationState();
}

class _VoiceCommandConfirmationState extends State<VoiceCommandConfirmation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _timeoutTimer;
  bool _isLoading = false;
  bool _dontAskAgain = false;
  bool _isListeningForVoice = true;

  // Mock command data
  final Map<String, dynamic> _commandData = {
    "commandText": "Delete the document file from my desktop",
    "interpretation":
        "This will permanently delete file: document.pdf from Desktop folder",
    "riskLevel": "critical",
    "systemName": "MacBook Pro - John's Office",
    "commandType": "file_deletion",
    "isVoiceCommand": true,
    "timestamp": DateTime.now(),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimeoutTimer();
    _simulateVoiceListening();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _handleCancel();
      }
    });
  }

  void _simulateVoiceListening() {
    // Simulate voice listening for demo purposes
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isListeningForVoice = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    _timeoutTimer?.cancel();
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop({'action': 'cancelled'});
      }
    });
  }

  void _handleExecute() async {
    setState(() {
      _isLoading = true;
    });

    _timeoutTimer?.cancel();

    // Simulate command execution
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _slideController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop({
            'action': 'executed',
            'dontAskAgain': _dontAskAgain,
            'commandType': _commandData['commandType'],
          });
        }
      });
    }
  }

  void _handleVoiceResponse(String response) {
    final String normalizedResponse = response.toLowerCase().trim();

    if (['yes', 'confirm', 'execute', 'ok'].contains(normalizedResponse)) {
      _handleExecute();
    } else if (['no', 'cancel', 'stop', 'abort'].contains(normalizedResponse)) {
      _handleCancel();
    }
  }

  void _handleBackgroundTap() {
    _handleCancel();
  }

  void _handleSwipeDown(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
      _handleCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _handleBackgroundTap,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.6),
            child: GestureDetector(
              onPanEnd: _handleSwipeDown,
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from propagating to background
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommandDetailsCard(
                            commandText: _commandData['commandText'] as String,
                            interpretation:
                                _commandData['interpretation'] as String,
                            riskLevel: _commandData['riskLevel'] as String,
                            systemName: _commandData['systemName'] as String,
                            isVoiceCommand:
                                _commandData['isVoiceCommand'] as bool,
                          ),
                          SizedBox(height: 2.h),
                          VoiceResponseListener(
                            onVoiceResponse: _handleVoiceResponse,
                            isListening: _isListeningForVoice,
                          ),
                          DontAskCheckbox(
                            value: _dontAskAgain,
                            onChanged: (value) {
                              setState(() {
                                _dontAskAgain = value ?? false;
                              });
                            },
                            commandType: _commandData['commandType'] as String,
                          ),
                          SizedBox(height: 2.h),
                          ActionButtons(
                            onCancel: _handleCancel,
                            onExecute: _handleExecute,
                            riskLevel: _commandData['riskLevel'] as String,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
