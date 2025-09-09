import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusBar extends StatelessWidget {
  final bool isConnected;
  final String systemName;
  final VoidCallback onConnectionTap;

  const ConnectionStatusBar({
    Key? key,
    required this.isConnected,
    required this.systemName,
    required this.onConnectionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.lightTheme.colorScheme.tertiaryContainer
            : AppTheme.lightTheme.colorScheme.errorContainer,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: onConnectionTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? 'Connected to Desktop'
                          : 'Desktop Disconnected',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isConnected
                            ? AppTheme
                                .lightTheme.colorScheme.onTertiaryContainer
                            : AppTheme.lightTheme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (systemName.isNotEmpty) ...[
                      SizedBox(height: 0.2.h),
                      Text(
                        systemName,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isConnected
                              ? AppTheme
                                  .lightTheme.colorScheme.onTertiaryContainer
                              : AppTheme
                                  .lightTheme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: isConnected ? 'computer' : 'computer_outlined',
                color: isConnected
                    ? AppTheme.lightTheme.colorScheme.onTertiaryContainer
                    : AppTheme.lightTheme.colorScheme.onErrorContainer,
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
