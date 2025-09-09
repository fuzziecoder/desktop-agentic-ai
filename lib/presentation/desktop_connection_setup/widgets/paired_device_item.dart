import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PairedDeviceItem extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onRename;

  const PairedDeviceItem({
    Key? key,
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
    required this.onRename,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'offline':
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      case 'error':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'check_circle';
      case 'offline':
        return 'radio_button_unchecked';
      case 'error':
        return 'error';
      default:
        return 'help';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = (device['name'] as String?) ?? 'Unknown Device';
    final String status = (device['status'] as String?) ?? 'offline';
    final String lastSeen = (device['lastSeen'] as String?) ?? 'Never';
    final String deviceType = (device['type'] as String?) ?? 'desktop';

    return Dismissible(
      key: Key(device['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Device Actions'),
                content: Text('What would you like to do with "$name"?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      onRename();
                    },
                    child: Text('Rename'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      onDisconnect();
                    },
                    child: Text(
                      'Disconnect',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.h,
          ),
          leading: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: deviceType == 'laptop' ? 'laptop' : 'computer',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      status.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.5.h),
              Text(
                'Last seen: $lastSeen',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (device['ip'] != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  'IP: ${device['ip']}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          trailing: status.toLowerCase() == 'online'
              ? ElevatedButton(
                  onPressed: onConnect,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    minimumSize: Size(0, 4.h),
                  ),
                  child: Text(
                    'Connect',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    minimumSize: Size(0, 4.h),
                  ),
                  child: Text(
                    'Unavailable',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
