import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onExecute;
  final String riskLevel;
  final bool isLoading;

  const ActionButtons({
    Key? key,
    required this.onCancel,
    required this.onExecute,
    required this.riskLevel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildCancelButton(context),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _buildExecuteButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      height: 6.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoading) ...[
              CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
            ],
            Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecuteButton(BuildContext context) {
    final Color buttonColor = _getExecuteButtonColor();

    return SizedBox(
      height: 6.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onExecute,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: buttonColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Executing...',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              CustomIconWidget(
                iconName: _getExecuteIcon(),
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Execute Command',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getExecuteButtonColor() {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'caution':
        return const Color(0xFFD97706); // Warning color
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getExecuteIcon() {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return 'warning';
      case 'caution':
        return 'play_arrow';
      default:
        return 'check';
    }
  }
}
