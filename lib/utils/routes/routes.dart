import 'package:talknest/models/group.dart';
import 'package:talknest/models/group_message.dart';
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
        final AppUser user = settings.arguments as AppUser;
        return MaterialPageRoute(
            builder: (_) => UserChatScreen(
                  user: user,
                ));
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.userprofileScreen:
        final AppUser user = settings.arguments as AppUser;
        return MaterialPageRoute(
            builder: (_) => UserProfileScreen(
                  user: user,
                ));
      case RouteNames.profileScreen:
        return MaterialPageRoute(builder: (_) => const Profilescreen());
      case RouteNames.contactScreen:
        return MaterialPageRoute(builder: (_) => const ContactScreen());
      case RouteNames.groupcreationScreen:
        return MaterialPageRoute(builder: (_) => const GroupCreationScreen());
      case RouteNames.groupScreen:
        return MaterialPageRoute(builder: (_) => const GroupScreen());
      case RouteNames.groupchatScreen:
        final Group group = settings.arguments as Group;
        return MaterialPageRoute(
            builder: (_) => GroupChatScreen(
                  group: group,
                ));
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
