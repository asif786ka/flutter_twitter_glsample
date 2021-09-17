import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_twitter_glsample/blocs/auth/auth_bloc.dart';
import 'package:flutter_twitter_glsample/screens/login/login_screen.dart';
import 'package:flutter_twitter_glsample/screens/nav/nav_screen.dart';


class SplashScreen extends StatelessWidget {
  static const String routeName = '/splash';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => SplashScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prevState, state) =>
        prevState.status !=
            state
                .status, // Prevent listener from triggering if status did not change
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            // Go to the Login Screen.
            Navigator.of(context).pushNamed(LoginScreen.routeName);
          } else if (state.status == AuthStatus.authenticated) {
            // Go to the Nav Screen.
            Navigator.of(context).pushNamed(NavScreen.routeName);
          }
        },
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}