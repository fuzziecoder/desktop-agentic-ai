import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  String _statusMessage = "Initializing...";
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      // Step 1: Check authentication tokens
      await _updateProgress(0.2, "Checking authentication...");
      await Future.delayed(const Duration(milliseconds: 500));
      bool isAuthenticated = await _checkAuthenticationTokens();

      // Step 2: Scan for paired desktop systems
      await _updateProgress(0.4, "Scanning for desktop connections...");
      await Future.delayed(const Duration(milliseconds: 700));
      bool hasDesktopConnection = await _scanForDesktopSystems();

      // Step 3: Load voice command cache
      await _updateProgress(0.6, "Loading voice command cache...");
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadVoiceCommandCache();

      // Step 4: Initialize speech recognition services
      await _updateProgress(0.8, "Initializing speech services...");
      await Future.delayed(const Duration(milliseconds: 600));
      bool speechInitialized = await _initializeSpeechRecognition();

      // Step 5: Complete initialization
      await _updateProgress(1.0, "Ready!");
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigation logic
      await _navigateToNextScreen(
          isAuthenticated, hasDesktopConnection, speechInitialized);
    } catch (e) {
      await _handleInitializationError(e);
    }
  }

  Future<void> _updateProgress(double progress, String message) async {
    if (mounted) {
      setState(() {
        _progress = progress;
        _statusMessage = message;
      });
    }
  }

  Future<bool> _checkAuthenticationTokens() async {
    // Simulate checking stored authentication tokens
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock: Return true if user has valid tokens
    return true; // In real app, check SharedPreferences or secure storage
  }

  Future<bool> _scanForDesktopSystems() async {
    // Simulate scanning for paired desktop systems on network
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: Return true if desktop connection found
    return false; // In real app, scan network for paired systems
  }

  Future<void> _loadVoiceCommandCache() async {
    // Simulate loading cached voice commands and patterns
    await Future.delayed(const Duration(milliseconds: 200));
    // In real app, load from local storage
  }

  Future<bool> _initializeSpeechRecognition() async {
    // Simulate initializing speech recognition services
    await Future.delayed(const Duration(milliseconds: 400));
    // Mock: Return true if speech services initialized successfully
    return true; // In real app, initialize speech_to_text package
  }

  Future<void> _navigateToNextScreen(bool isAuthenticated,
      bool hasDesktopConnection, bool speechInitialized) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (!isAuthenticated) {
      // New users or users without authentication
      Navigator.pushReplacementNamed(context, '/authentication-screen');
    } else if (!hasDesktopConnection) {
      // Authenticated users without paired desktop systems
      Navigator.pushReplacementNamed(context, '/desktop-connection-setup');
    } else {
      // Authenticated users with active desktop connections
      Navigator.pushReplacementNamed(context, '/command-interface');
    }
  }

  Future<void> _handleInitializationError(dynamic error) async {
    if (mounted) {
      setState(() {
        _statusMessage = "Connection timeout";
        _isInitializing = false;
      });
    }
  }

  void _continueOffline() {
    Navigator.pushReplacementNamed(context, '/command-interface');
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _progress = 0.0;
      _statusMessage = "Initializing...";
    });
    _startInitialization();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.tertiary,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo with Pulse Animation
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 25.w,
                            height: 25.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'mic',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 8.w,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Flutter\nAssistant',
                                  textAlign: TextAlign.center,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Status and Progress Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Status Message
                        Text(
                          _statusMessage,
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Progress Indicator or Error Actions
                        _isInitializing
                            ? _buildProgressIndicator()
                            : _buildErrorActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Progress Bar
        Container(
          width: 60.w,
          height: 0.8.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1.h),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60.w * _progress,
                height: 0.8.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.h),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Progress Percentage
        Text(
          '${(_progress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorActions() {
    return Column(
      children: [
        // Continue Offline Button
        SizedBox(
          width: 60.w,
          child: ElevatedButton(
            onPressed: _continueOffline,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.lightTheme.colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: Text(
              'Continue Offline',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Retry Button
        TextButton(
          onPressed: _retryInitialization,
          child: Text(
            'Retry Connection',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 12.sp,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
