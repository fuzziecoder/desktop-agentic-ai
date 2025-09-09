import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum CommandStatus { idle, executing, completed, error }

class CommandStatusCard extends StatelessWidget {
  final CommandStatus status;
  final String message;
  final VoidCallback? onRetry;
  final bool isVisible;

  const CommandStatusCard({
    Key? key,
    required this.status,
    required this.message,
    this.onRetry,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildStatusIcon(),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(),
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: _getTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      message,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (status == CommandStatus.error && onRetry != null) ...[
              SizedBox(width: 2.w),
              IconButton(
                onPressed: onRetry,
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 5.w,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case CommandStatus.executing:
        return SizedBox(
          width: 5.w,
          height: 5.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        );
      case CommandStatus.completed:
        return CustomIconWidget(
          iconName: 'check_circle',
          color: AppTheme.lightTheme.colorScheme.tertiary,
          size: 5.w,
        );
      case CommandStatus.error:
        return CustomIconWidget(
          iconName: 'error',
          color: AppTheme.lightTheme.colorScheme.error,
          size: 5.w,
        );
      default:
        return CustomIconWidget(
          iconName: 'info',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        );
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case CommandStatus.executing:
        return 'Executing on Desktop...';
      case CommandStatus.completed:
        return 'Command Completed';
      case CommandStatus.error:
        return 'Command Failed';
      default:
        return 'Ready';
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case CommandStatus.executing:
        return AppTheme.lightTheme.colorScheme.primaryContainer;
      case CommandStatus.completed:
        return AppTheme.lightTheme.colorScheme.tertiaryContainer;
      case CommandStatus.error:
        return AppTheme.lightTheme.colorScheme.errorContainer;
      default:
        return AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case CommandStatus.executing:
        return AppTheme.lightTheme.colorScheme.primary;
      case CommandStatus.completed:
        return AppTheme.lightTheme.colorScheme.tertiary;
      case CommandStatus.error:
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case CommandStatus.executing:
        return AppTheme.lightTheme.colorScheme.onPrimaryContainer;
      case CommandStatus.completed:
        return AppTheme.lightTheme.colorScheme.onTertiaryContainer;
      case CommandStatus.error:
        return AppTheme.lightTheme.colorScheme.onErrorContainer;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
