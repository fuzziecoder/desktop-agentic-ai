import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionProgressDialog extends StatefulWidget {
  final String currentStep;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const ConnectionProgressDialog({
    Key? key,
    required this.currentStep,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ConnectionProgressDialog> createState() =>
      _ConnectionProgressDialogState();
}

class _ConnectionProgressDialogState extends State<ConnectionProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _successController;
  late Animation<double> _progressAnimation;
  late Animation<double> _successAnimation;

  final List<String> _steps = [
    'Discovering device',
    'Establishing secure connection',
    'Verifying credentials',
    'Connection established',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _progressController.repeat();

    if (widget.isSuccess) {
      _progressController.stop();
      _successController.forward();
    }
  }

  @override
  void didUpdateWidget(ConnectionProgressDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _progressController.stop();
      _successController.forward();
    } else if (widget.isError && !oldWidget.isError) {
      _progressController.stop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _successController.dispose();
    super.dispose();
  }

  int get _currentStepIndex {
    return _steps.indexOf(widget.currentStep);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: widget.isError
                    ? AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1)
                    : widget.isSuccess
                        ? AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: widget.isError
                    ? CustomIconWidget(
                        iconName: 'error',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 10.w,
                      )
                    : widget.isSuccess
                        ? ScaleTransition(
                            scale: _successAnimation,
                            child: CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 10.w,
                            ),
                          )
                        : RotationTransition(
                            turns: _progressAnimation,
                            child: CustomIconWidget(
                              iconName: 'sync',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 10.w,
                            ),
                          ),
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              widget.isError
                  ? 'Connection Failed'
                  : widget.isSuccess
                      ? 'Connected Successfully!'
                      : 'Connecting to Desktop',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.isError
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Progress Steps or Error Message
            if (widget.isError) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.errorMessage ??
                      'An unexpected error occurred. Please try again.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else if (widget.isSuccess) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your device is now connected and ready to receive commands.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              Column(
                children: _steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isActive = index == _currentStepIndex;
                  final isCompleted = index < _currentStepIndex;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 0.5.h),
                    child: Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : isActive
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: isCompleted
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: Colors.white,
                                    size: 3.w,
                                  )
                                : isActive
                                    ? SizedBox(
                                        width: 3.w,
                                        height: 3.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            step,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isActive || isCompleted
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isActive ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 4.h),

            // Action Buttons
            Row(
              children: [
                if (widget.isError && widget.onRetry != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onRetry,
                      child: Text('Retry'),
                    ),
                  ),
                ] else if (widget.isSuccess) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                            context, '/command-interface');
                      },
                      child: Text('Continue'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
