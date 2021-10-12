import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_twitter_glsample/blocs/auth/auth_bloc.dart';
import 'package:flutter_twitter_glsample/cubits/liked_posts/liked_posts_cubit.dart';
import 'package:flutter_twitter_glsample/models/models.dart';
import 'package:flutter_twitter_glsample/repositories/post/post_repository.dart';
import 'package:flutter_twitter_glsample/repositories/user/user_repository.dart';

import 'package:meta/meta.dart';

part 'allusers_posts_event.dart';
part 'allusers_posts_state.dart';

class AllUsersPostsBloc extends Bloc<AllUsersPostsEvent, AllUsersPostsState> {
  final UserRepository _userRepository;
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final LikedPostsCubit _likedPostsCubit;

  StreamSubscription<List<Future<Post>>> _postsSubscription;

  AllUsersPostsBloc({
    @required UserRepository userRepository,
    @required PostRepository postRepository,
    @required AuthBloc authBloc,
    @required LikedPostsCubit likedPostsCubit,
  })  : _userRepository = userRepository,
        _postRepository = postRepository,
        _authBloc = authBloc,
        _likedPostsCubit = likedPostsCubit,
        super(AllUsersPostsState.initial());

  @override
  Future<void> close() {
    _postsSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AllUsersPostsState> mapEventToState(
      AllUsersPostsEvent event,
      ) async* {
    if (event is AllUsersPostsLoadUser) {
      yield* _mapProfileLoadUserToState(event);
    } else if (event is ProfileToggleGridView) {
      yield* _mapProfileToggleGridViewToState(event);
    } else if (event is ProfileUpdatePosts) {
      yield* _mapProfileUpdatePostsToState(event);
    } else if (event is ProfileFollowUser) {
      yield* _mapProfileFollowUserToState();
    } else if (event is ProfileUnfollowUser) {
      yield* _mapProfileUnfollowUserToState();
    }
  }

  Stream<AllUsersPostsState> _mapProfileLoadUserToState(
      AllUsersPostsLoadUser event,
      ) async* {
    yield state.copyWith(status: ProfileStatus.loading);
    try {
      final user = await _userRepository.getUserWithId(userId: event.userId);
      final isCurrentUser = _authBloc.state.user.uid == event.userId;

      final isFollowing = await _userRepository.isFollowing(
        userId: _authBloc.state.user.uid,
        otherUserId: event.userId,
      );

      _postsSubscription?.cancel();
      _postsSubscription = _postRepository
          .getUserPosts(userId: event.userId)
          .listen((posts) async {
        final allPosts = await Future.wait(posts);
        add(ProfileUpdatePosts(posts: allPosts));
      });

      yield state.copyWith(
        user: user,
        isCurrentUser: isCurrentUser,
        isFollowing: isFollowing,
        status: ProfileStatus.loaded,
      );
    } catch (err) {
      yield state.copyWith(
        status: ProfileStatus.error,
        failure: Failure(message: 'We were unable to load this profile.'),
      );
    }
  }

  Stream<AllUsersPostsState> _mapProfileToggleGridViewToState(
      ProfileToggleGridView event,
      ) async* {
    yield state.copyWith(isGridView: event.isGridView);
  }

  Stream<AllUsersPostsState> _mapProfileUpdatePostsToState(
      ProfileUpdatePosts event,
      ) async* {
    yield state.copyWith(posts: event.posts);
    final likedPostIds = await _postRepository.getLikedPostIds(
      userId: _authBloc.state.user.uid,
      posts: event.posts,
    );
    _likedPostsCubit.updateLikedPosts(postIds: likedPostIds);
  }

  Stream<AllUsersPostsState> _mapProfileFollowUserToState() async* {
    try {
      _userRepository.followUser(
        userId: _authBloc.state.user.uid,
        followUserId: state.user.id,
      );
      final updatedUser =
      state.user.copyWith(followers: state.user.followers + 1);
      yield state.copyWith(user: updatedUser, isFollowing: true);
    } catch (err) {
      yield state.copyWith(
        status: ProfileStatus.error,
        failure:
        Failure(message: 'Something went wrong! Please try again.'),
      );
    }
  }

  Stream<AllUsersPostsState> _mapProfileUnfollowUserToState() async* {
    try {
      _userRepository.unfollowUser(
        userId: _authBloc.state.user.uid,
        unfollowUserId: state.user.id,
      );
      final updatedUser =
      state.user.copyWith(followers: state.user.followers - 1);
      yield state.copyWith(user: updatedUser, isFollowing: false);
    } catch (err) {
      yield state.copyWith(
        status: ProfileStatus.error,
        failure:
        Failure(message: 'Something went wrong! Please try again.'),
      );
    }
  }
}