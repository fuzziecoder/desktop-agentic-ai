import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentCommandsList extends StatelessWidget {
  final List<Map<String, dynamic>> commands;
  final Function(String) onRepeatCommand;
  final Function(int) onDeleteCommand;
  final VoidCallback onRefresh;
  final bool isLoading;

  const RecentCommandsList({
    Key? key,
    required this.commands,
    required this.onRepeatCommand,
    required this.onDeleteCommand,
    required this.onRefresh,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: commands.isEmpty && !isLoading
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final command = commands[index];
                  return _buildCommandItem(context, command, index);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No recent commands',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your command history will appear here',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommandItem(
      BuildContext context, Map<String, dynamic> command, int index) {
    final String commandText = command['command'] as String;
    final String status = command['status'] as String;
    final DateTime timestamp = command['timestamp'] as DateTime;
    final String result = command['result'] as String? ?? '';

    return Dismissible(
      key: Key('command_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      onDismissed: (direction) => onDeleteCommand(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onRepeatCommand(commandText),
            onLongPress: () => _showContextMenu(context, commandText, index),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          commandText,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _buildStatusBadge(status),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _formatTimestamp(timestamp),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      CustomIconWidget(
                        iconName: 'replay',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 4.w,
                      ),
                    ],
                  ),
                  if (result.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = AppTheme.lightTheme.colorScheme.tertiaryContainer;
        textColor = AppTheme.lightTheme.colorScheme.onTertiaryContainer;
        iconData = Icons.check_circle;
        break;
      case 'failed':
        backgroundColor = AppTheme.lightTheme.colorScheme.errorContainer;
        textColor = AppTheme.lightTheme.colorScheme.onErrorContainer;
        iconData = Icons.error;
        break;
      case 'executing':
        backgroundColor = AppTheme.lightTheme.colorScheme.primaryContainer;
        textColor = AppTheme.lightTheme.colorScheme.onPrimaryContainer;
        iconData = Icons.hourglass_empty;
        break;
      default:
        backgroundColor = AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
        textColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        iconData = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 3.w,
            color: textColor,
          ),
          SizedBox(width: 1.w),
          Text(
            status,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showContextMenu(BuildContext context, String command, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'replay',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Repeat Command'),
              onTap: () {
                Navigator.pop(context);
                onRepeatCommand(command);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Edit Command'),
              onTap: () {
                Navigator.pop(context);
                onRepeatCommand(command);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                onDeleteCommand(index);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
