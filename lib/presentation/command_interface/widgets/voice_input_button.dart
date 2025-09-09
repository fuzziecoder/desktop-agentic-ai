import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final bool isConnected;

  const VoiceInputButton({
    Key? key,
    required this.isRecording,
    required this.onPressed,
    required this.isConnected,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isRecording) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRecording ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isRecording
                  ? AppTheme.lightTheme.colorScheme.error
                  : widget.isConnected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: widget.isRecording
                      ? AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.3)
                      : AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                  blurRadius: widget.isRecording ? 20 : 8,
                  spreadRadius: widget.isRecording ? 4 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10.w),
                onTap: widget.isConnected ? widget.onPressed : null,
                child: Center(
                  child: CustomIconWidget(
                    iconName: widget.isRecording ? 'stop' : 'mic',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
