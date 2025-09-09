import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommandInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onMicPressed;
  final VoidCallback onSendPressed;
  final bool isEnabled;
  final bool hasText;

  const CommandInputField({
    Key? key,
    required this.controller,
    required this.onMicPressed,
    required this.onSendPressed,
    required this.isEnabled,
    required this.hasText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEnabled,
              decoration: InputDecoration(
                hintText: 'Type a command...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              maxLines: 3,
              minLines: 1,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 2.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: isEnabled ? onMicPressed : null,
                  icon: CustomIconWidget(
                    iconName: 'mic',
                    color: isEnabled
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 1.w),
                IconButton(
                  onPressed: (isEnabled && hasText) ? onSendPressed : null,
                  icon: CustomIconWidget(
                    iconName: 'send',
                    color: (isEnabled && hasText)
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
