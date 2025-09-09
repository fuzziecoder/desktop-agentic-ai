import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommandSuggestions extends StatelessWidget {
  final Function(String) onSuggestionTapped;
  final bool isEnabled;

  const CommandSuggestions({
    Key? key,
    required this.onSuggestionTapped,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = [
      {'text': 'Open Documents', 'icon': 'folder'},
      {'text': 'Launch Chrome', 'icon': 'web'},
      {'text': 'Search for...', 'icon': 'search'},
      {'text': 'Open Downloads', 'icon': 'download'},
      {'text': 'Launch VS Code', 'icon': 'code'},
      {'text': 'System Info', 'icon': 'info'},
    ];

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: ActionChip(
              onPressed: isEnabled
                  ? () => onSuggestionTapped(suggestion['text'] as String)
                  : null,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: suggestion['icon'] as String,
                    color: isEnabled
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    suggestion['text'] as String,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isEnabled
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              backgroundColor: isEnabled
                  ? AppTheme.lightTheme.colorScheme.primaryContainer
                  : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: isEnabled
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
