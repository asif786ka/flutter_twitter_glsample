part of 'allusers_posts_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error }

class AllUsersPostsState extends Equatable {
  final User user;
  final List<Post> posts;
  final bool isCurrentUser;
  final bool isGridView;
  final bool isFollowing;
  final ProfileStatus status;
  final Failure failure;

  const AllUsersPostsState({
    @required this.user,
    @required this.posts,
    @required this.isCurrentUser,
    @required this.isGridView,
    @required this.isFollowing,
    @required this.status,
    @required this.failure,
  });

  factory AllUsersPostsState.initial() {
    return AllUsersPostsState(
      user: User.empty,
      posts: [],
      isCurrentUser: false,
      isGridView: true,
      isFollowing: false,
      status: ProfileStatus.initial,
      failure: Failure(),
    );
  }

  @override
  List<Object> get props => [
    user,
    posts,
    isCurrentUser,
    isGridView,
    isFollowing,
    status,
    failure,
  ];

  AllUsersPostsState copyWith({
    User user,
    List<Post> posts,
    bool isCurrentUser,
    bool isGridView,
    bool isFollowing,
    ProfileStatus status,
    Failure failure,
  }) {
    return AllUsersPostsState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isGridView: isGridView ?? this.isGridView,
      isFollowing: isFollowing ?? this.isFollowing,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}