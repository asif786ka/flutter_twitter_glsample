import 'package:flutter/material.dart';
import 'package:flutter_twitter_glsample/screens/allusers_posts/allusers_posts_screen.dart';
import 'package:flutter_twitter_glsample/screens/comments/comments_screen.dart';
import 'package:flutter_twitter_glsample/screens/edit_profile/edit_profile_screen.dart';
import 'package:flutter_twitter_glsample/screens/login/login_screen.dart';
import 'package:flutter_twitter_glsample/screens/nav/nav_screen.dart';
import 'package:flutter_twitter_glsample/screens/profile/profile_screen.dart';
import 'package:flutter_twitter_glsample/screens/signup/signup_screen.dart';
import 'package:flutter_twitter_glsample/screens/splash/splash_screen.dart';

class CustomRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    print('Route: ${settings.name}');
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const Scaffold(),
        );
      case SplashScreen.routeName:
        return SplashScreen.route();
      case LoginScreen.routeName:
        return LoginScreen.route();
      case SignupScreen.routeName:
        return SignupScreen.route();
      case NavScreen.routeName:
        return NavScreen.route();
      default:
        return _errorRoute();
    }
  }

  static Route onGenerateNestedRoute(RouteSettings settings) {
    print('Nested Route: ${settings.name}');
    switch (settings.name) {
      case ProfileScreen.routeName:
        return ProfileScreen.route(args: settings.arguments);
      case AllUsersPostsScreen.routeName:
        return AllUsersPostsScreen.route(args: settings.arguments);
      case EditProfileScreen.routeName:
        return EditProfileScreen.route(args: settings.arguments);
      case CommentsScreen.routeName:
        return CommentsScreen.route(args: settings.arguments);
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Something went wrong!'),
        ),
      ),
    );
  }
}