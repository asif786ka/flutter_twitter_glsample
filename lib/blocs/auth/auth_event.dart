part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  // TODO: implement stringify
  bool get stringify => true;
  @override
  List<Object> get props => [];
}

//This event is called whenever firebase signs in a specific user.
class AuthUserChanged extends AuthEvent {
  final auth.User user;

  const AuthUserChanged({@required this.user});

  @override
  List<Object> get props => [user];
}

//This event is called whenever firebase signs out in a specific user.
class AuthLogoutRequested extends AuthEvent {
}
