import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class PinAuthWidget extends StatefulWidget {
  final VoidCallback onPinSuccess;
  final VoidCallback onBackToBiometric;
  final bool isLoading;

  const PinAuthWidget({
    Key? key,
    required this.onPinSuccess,
    required this.onBackToBiometric,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PinAuthWidget> createState() => _PinAuthWidgetState();
}

class _PinAuthWidgetState extends State<PinAuthWidget> {
  String _enteredPin = '';
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockoutSeconds = 0;
  final String _correctPin = '1234'; // Mock PIN for demonstration
  final int _maxAttempts = 3;
  final int _lockoutDuration = 30; // 30 seconds lockout

  @override
  void initState() {
    super.initState();
  }

  void _onNumberPressed(String number) {
    if (widget.isLoading || _isLocked || _enteredPin.length >= 6) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += number;
    });

    if (_enteredPin.length == 4) {
      _validatePin();
    }
  }

  void _onDeletePressed() {
    if (widget.isLoading || _isLocked || _enteredPin.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _validatePin() async {
    if (_enteredPin == _correctPin) {
      HapticFeedback.notificationImpact(NotificationFeedbackType.success);
      setState(() {
        _failedAttempts = 0;
      });
      widget.onPinSuccess();
    } else {
      HapticFeedback.notificationImpact(NotificationFeedbackType.error);
      setState(() {
        _failedAttempts++;
        _enteredPin = '';
      });

      if (_failedAttempts >= _maxAttempts) {
        _startLockout();
      } else {
        _showErrorMessage();
      }
    }
  }

  void _startLockout() {
    setState(() {
      _isLocked = true;
      _lockoutSeconds = _lockoutDuration;
    });

    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _lockoutSeconds > 0) {
        setState(() {
          _lockoutSeconds--;
        });
        _startCountdown();
      } else if (mounted) {
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
        });
      }
    });
  }

  void _showErrorMessage() {
    final remainingAttempts = _maxAttempts - _failedAttempts;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Incorrect PIN. $remainingAttempts attempt${remainingAttempts == 1 ? '' : 's'} remaining.',
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

  Widget _buildPinDot(int index) {
    final bool isFilled = index < _enteredPin.length;
    return Container(
      width: 4.w,
      height: 4.w,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppTheme.lightTheme.primaryColor : Colors.transparent,
        border: Border.all(
          color: isFilled
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.outline,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isLocked
              ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: _isLocked
                ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: _isLocked
                  ? AppTheme.lightTheme.colorScheme.outline
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          'Enter PIN',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 2.h),

        // PIN Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) => _buildPinDot(index)),
        ),

        SizedBox(height: 2.h),

        // Error/Status Message
        Container(
          height: 6.h,
          child: _isLocked
              ? Column(
                  children: [
                    Text(
                      'Too many failed attempts',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.errorLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Try again in $_lockoutSeconds seconds',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : _failedAttempts > 0
                  ? Text(
                      'Incorrect PIN. ${_maxAttempts - _failedAttempts} attempts remaining.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.errorLight,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      'Enter your 4-digit PIN',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
        ),

        SizedBox(height: 4.h),

        // Number Pad
        Column(
          children: [
            // Row 1: 1, 2, 3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['1', '2', '3']
                  .map((number) => _buildNumberButton(number))
                  .toList(),
            ),
            SizedBox(height: 3.h),

            // Row 2: 4, 5, 6
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['4', '5', '6']
                  .map((number) => _buildNumberButton(number))
                  .toList(),
            ),
            SizedBox(height: 3.h),

            // Row 3: 7, 8, 9
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['7', '8', '9']
                  .map((number) => _buildNumberButton(number))
                  .toList(),
            ),
            SizedBox(height: 3.h),

            // Row 4: Empty, 0, Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 18.w), // Empty space
                _buildNumberButton('0'),
                GestureDetector(
                  onTap: _onDeletePressed,
                  child: Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLocked
                          ? AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      border: Border.all(
                        color: _isLocked
                            ? AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'backspace',
                        size: 6.w,
                        color: _isLocked
                            ? AppTheme.lightTheme.colorScheme.outline
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Forgot PIN / Contact Support
        if (_isLocked) ...[
          TextButton(
            onPressed: () {
              // Show contact support dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Contact Support',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  content: Text(
                    'Please contact support at support@flutterassistant.com for assistance with PIN recovery.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'Contact Support',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: widget.isLoading ? null : widget.onBackToBiometric,
            child: Text(
              'Back to Biometric',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
