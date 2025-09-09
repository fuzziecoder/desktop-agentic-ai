import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final VoidCallback onUsePinPressed;
  final bool isLoading;

  const BiometricAuthWidget({
    Key? key,
    required this.onBiometricSuccess,
    required this.onUsePinPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isBiometricAvailable = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Simulate biometric availability check
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isBiometricAvailable = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (widget.isLoading) return;

    try {
      HapticFeedback.lightImpact();

      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        HapticFeedback.notificationImpact(NotificationFeedbackType.success);
        widget.onBiometricSuccess();
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.notificationImpact(NotificationFeedbackType.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biometric authentication failed. Please try again.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Biometric Icon with Animation
        GestureDetector(
          onTap: _authenticateWithBiometrics,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isLoading ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isBiometricAvailable
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                    border: Border.all(
                      color: _isBiometricAvailable
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: widget.isLoading
                      ? Center(
                          child: SizedBox(
                            width: 8.w,
                            height: 8.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.primaryColor,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: CustomIconWidget(
                            iconName: 'fingerprint',
                            size: 10.w,
                            color: _isBiometricAvailable
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 4.h),

        // Authentication Instruction
        Text(
          widget.isLoading ? 'Authenticating...' : 'Authenticate to Continue',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        // Biometric Status Text
        Text(
          _isBiometricAvailable
              ? 'Touch the fingerprint sensor or use Face ID'
              : 'Biometric authentication not available',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 6.h),

        // Use PIN Instead Button
        TextButton(
          onPressed: widget.isLoading ? null : widget.onUsePinPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Use PIN Instead',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
