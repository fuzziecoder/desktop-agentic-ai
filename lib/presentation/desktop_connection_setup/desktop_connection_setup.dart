import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_method_card.dart';
import './widgets/connection_progress_dialog.dart';
import './widgets/manual_setup_form.dart';
import './widgets/paired_device_item.dart';
import './widgets/qr_scanner_overlay.dart';

class DesktopConnectionSetup extends StatefulWidget {
  const DesktopConnectionSetup({Key? key}) : super(key: key);

  @override
  State<DesktopConnectionSetup> createState() => _DesktopConnectionSetupState();
}

class _DesktopConnectionSetupState extends State<DesktopConnectionSetup> {
  bool _showManualSetup = false;
  bool _isConnecting = false;
  String _connectionStep = 'Discovering device';

  // Mock data for previously paired devices
  final List<Map<String, dynamic>> _pairedDevices = [
    {
      "id": 1,
      "name": "MacBook Pro - Office",
      "type": "laptop",
      "status": "online",
      "lastSeen": "2 minutes ago",
      "ip": "192.168.1.105",
    },
    {
      "id": 2,
      "name": "Windows Desktop - Home",
      "type": "desktop",
      "status": "offline",
      "lastSeen": "1 hour ago",
      "ip": "192.168.1.110",
    },
    {
      "id": 3,
      "name": "Linux Workstation",
      "type": "desktop",
      "status": "error",
      "lastSeen": "Yesterday",
      "ip": "192.168.1.115",
    },
  ];

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _openQRScanner();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text(
            'Please grant camera permission to scan QR codes for device pairing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerOverlay(
          onQRScanned: _handleQRScanned,
          onClose: () => Navigator.of(context).pop(),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleQRScanned(String qrData) {
    Navigator.of(context).pop(); // Close scanner

    try {
      // Parse QR data (mock implementation)
      final parts = qrData.split('|');
      if (parts.length >= 3) {
        final ip = parts[0];
        final port = parts[1];
        final code = parts[2];
        _connectToDesktop(ip, port, code);
      } else {
        _showErrorSnackBar('Invalid QR code format');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to parse QR code');
    }
  }

  void _connectToDesktop(String ip, String port, String code) {
    setState(() {
      _isConnecting = true;
      _connectionStep = 'Discovering device';
    });

    _showConnectionDialog();
    _simulateConnection(ip, port, code);
  }

  void _simulateConnection(String ip, String port, String code) async {
    // Mock connection process with realistic steps
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _connectionStep = 'Establishing secure connection');
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _connectionStep = 'Verifying credentials');
    await Future.delayed(Duration(seconds: 1));
    if (!mounted) return;

    // Mock validation - fail if using demo credentials incorrectly
    if (code == '123456' && ip == '192.168.1.100' && port == '8080') {
      setState(() {
        _connectionStep = 'Connection established';
        _isConnecting = false;
      });

      // Show success dialog
      Navigator.of(context).pop(); // Close progress dialog
      _showConnectionDialog(isSuccess: true);
    } else {
      setState(() => _isConnecting = false);
      Navigator.of(context).pop(); // Close progress dialog
      _showConnectionDialog(
        isError: true,
        errorMessage:
            'Invalid credentials. Use IP: 192.168.1.100, Port: 8080, Code: 123456',
      );
    }
  }

  void _showConnectionDialog({
    bool isSuccess = false,
    bool isError = false,
    String? errorMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConnectionProgressDialog(
        currentStep: _connectionStep,
        isSuccess: isSuccess,
        isError: isError,
        errorMessage: errorMessage,
        onRetry: isError
            ? () {
                Navigator.of(context).pop();
                setState(() => _showManualSetup = true);
              }
            : null,
        onCancel: () {
          Navigator.of(context).pop();
          setState(() {
            _isConnecting = false;
            _showManualSetup = false;
          });
        },
      ),
    );
  }

  void _connectToPairedDevice(Map<String, dynamic> device) {
    final String ip = (device['ip'] as String?) ?? '';
    _connectToDesktop(ip, '8080', '123456');
  }

  void _disconnectDevice(Map<String, dynamic> device) {
    setState(() {
      device['status'] = 'offline';
      device['lastSeen'] = 'Just now';
    });
    _showSuccessSnackBar('Device disconnected');
  }

  void _renameDevice(Map<String, dynamic> device) {
    final controller = TextEditingController(text: device['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Device'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Device Name',
            hintText: 'Enter new name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  device['name'] = controller.text;
                });
                Navigator.of(context).pop();
                _showSuccessSnackBar('Device renamed successfully');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'help',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text('Setup Instructions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code Method:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '1. Install Flutter Assistant Desktop on your computer\n'
                '2. Open the app and go to Mobile Pairing\n'
                '3. Click "Generate QR Code"\n'
                '4. Scan the QR code with this app',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Manual Setup:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '1. Find your computer\'s IP address\n'
                '2. Note the port number from desktop app\n'
                '3. Get the 6-digit pairing code\n'
                '4. Enter all details in Manual Setup',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Credentials:',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'IP: 192.168.1.100\nPort: 8080\nCode: 123456',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Desktop Connection'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'wifi',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'READY',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
              ],
            ),
          ),
          IconButton(
            onPressed: _showHelpDialog,
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Methods
            Text(
              'Choose Connection Method',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Select how you\'d like to connect to your desktop computer',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),

            // Connection Method Cards
            Row(
              children: [
                Expanded(
                  child: ConnectionMethodCard(
                    title: 'Scan QR Code',
                    description: 'Quick setup using camera',
                    iconName: 'qr_code_scanner',
                    onTap: _requestCameraPermission,
                    isEnabled: !_isConnecting,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ConnectionMethodCard(
                    title: 'Manual Setup',
                    description: 'Enter details manually',
                    iconName: 'keyboard',
                    onTap: () =>
                        setState(() => _showManualSetup = !_showManualSetup),
                    isEnabled: !_isConnecting,
                  ),
                ),
              ],
            ),

            // Manual Setup Form
            if (_showManualSetup) ...[
              SizedBox(height: 3.h),
              ManualSetupForm(
                onConnect: _connectToDesktop,
                isLoading: _isConnecting,
              ),
            ],

            SizedBox(height: 4.h),

            // Previously Paired Devices
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'devices',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Previously Paired Devices',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            if (_pairedDevices.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'computer',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 12.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No Paired Devices',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Connect to your first desktop to get started',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _pairedDevices.length,
                itemBuilder: (context, index) {
                  final device = _pairedDevices[index];
                  return PairedDeviceItem(
                    device: device,
                    onConnect: () => _connectToPairedDevice(device),
                    onDisconnect: () => _disconnectDevice(device),
                    onRename: () => _renameDevice(device),
                  );
                },
              ),
            ],

            SizedBox(height: 4.h),

            // Security Notice
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Connection',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'All connections are encrypted end-to-end. Your data remains private and secure.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
