import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceSensitivityWidget extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const VoiceSensitivityWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<VoiceSensitivityWidget> createState() => _VoiceSensitivityWidgetState();
}

class _VoiceSensitivityWidgetState extends State<VoiceSensitivityWidget> {
  late double _currentValue;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _testVoiceSensitivity() async {
    setState(() {
      _isTesting = true;
    });

    // Simulate voice test
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isTesting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice sensitivity test completed'),
          backgroundColor: AppTheme.successLight,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voice Sensitivity',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: _isTesting ? null : _testVoiceSensitivity,
                icon: _isTesting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'mic',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                label: Text(_isTesting ? 'Testing...' : 'Test'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Low',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _currentValue,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                  inactiveColor: AppTheme.lightTheme.colorScheme.outline,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                    widget.onChanged(value);
                  },
                ),
              ),
              Text(
                'High',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Current: ${(_currentValue * 100).round()}%',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
