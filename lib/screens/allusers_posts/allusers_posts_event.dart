part of 'allusers_posts_bloc.dart';

abstract class AllUsersPostsEvent extends Equatable {
  const AllUsersPostsEvent();

  @override
  List<Object> get props => [];
}

class AllUsersPostsLoadUser extends AllUsersPostsEvent {
  final String userId;

  const AllUsersPostsLoadUser({@required this.userId});

  @override
  List<Object> get props => [userId];
}

class ProfileToggleGridView extends AllUsersPostsEvent {
  final bool isGridView;

  const ProfileToggleGridView({@required this.isGridView});

  @override
  List<Object> get props => [isGridView];
}

class ProfileUpdatePosts extends AllUsersPostsEvent {
  final List<Post> posts;

  const ProfileUpdatePosts({@required this.posts});

  @override
  List<Object> get props => [posts];
}

class ProfileFollowUser extends AllUsersPostsEvent {}

class ProfileUnfollowUser extends AllUsersPostsEvent {}
