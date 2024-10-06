import 'package:flutter/material.dart';
import 'package:talknest/utils/routes/export_file.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case RouteNames.auth:
        return MaterialPageRoute(builder: (_) => const Authscreen());
         case RouteNames.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
         case RouteNames.userChatScreen:
        return MaterialPageRoute(builder: (_) => const UserChatScreen());
          case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        case RouteNames.profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}
