import 'package:flutter/material.dart';
import '../presentation/voice_command_confirmation/voice_command_confirmation.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/desktop_connection_setup/desktop_connection_setup.dart';
import '../presentation/command_interface/command_interface.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String voiceCommandConfirmation = '/voice-command-confirmation';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String authentication = '/authentication-screen';
  static const String desktopConnectionSetup = '/desktop-connection-setup';
  static const String commandInterface = '/command-interface';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    voiceCommandConfirmation: (context) => const VoiceCommandConfirmation(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    authentication: (context) => const AuthenticationScreen(),
    desktopConnectionSetup: (context) => const DesktopConnectionSetup(),
    commandInterface: (context) => const CommandInterface(),
    // TODO: Add your other routes here
  };
}
