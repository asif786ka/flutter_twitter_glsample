import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_twitter_glsample/blocs/auth/auth_bloc.dart';
import 'package:flutter_twitter_glsample/cubits/liked_posts/liked_posts_cubit.dart';
import 'package:flutter_twitter_glsample/screens/allusers_posts/allusers_posts_bloc.dart';
import 'package:flutter_twitter_glsample/screens/comments/comments_screen.dart';
import 'package:flutter_twitter_glsample/repositories/post/post_repository.dart';
import 'package:flutter_twitter_glsample/repositories/user/user_repository.dart';
import 'package:flutter_twitter_glsample/screens/profile/widgets/profile_info.dart';
import 'package:flutter_twitter_glsample/screens/profile/widgets/profile_stats.dart';
import 'package:flutter_twitter_glsample/widgets/error_dialog.dart';
import 'package:flutter_twitter_glsample/widgets/post_view.dart';
import 'package:flutter_twitter_glsample/widgets/user_profile_image.dart';


class AllUsersPostsScreenArgs {
  final String userId;

  const AllUsersPostsScreenArgs({@required this.userId});
}

class AllUsersPostsScreen extends StatefulWidget {
  static const String routeName = '/allusersposts';

  static Route route({@required AllUsersPostsScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<AllUsersPostsBloc>(
        create: (_) => AllUsersPostsBloc(
          userRepository: context.read<UserRepository>(),
          postRepository: context.read<PostRepository>(),
          authBloc: context.read<AuthBloc>(),
          likedPostsCubit: context.read<LikedPostsCubit>(),
        )..add(AllUsersPostsLoadUser(userId: args.userId)),
        child: AllUsersPostsScreen(),
      ),
    );
  }

  @override
  _AllUsersPostsScreenState createState() => _AllUsersPostsScreenState();
}

class _AllUsersPostsScreenState extends State<AllUsersPostsScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AllUsersPostsBloc, AllUsersPostsState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(content: state.failure.message),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0.0,
            titleSpacing: 10.0,
            centerTitle: true,
            title: Text(state.user.username),
            actions: [
              if (state.isCurrentUser)
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    context.read<LikedPostsCubit>().clearAllLikedPosts();
                  },
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(AllUsersPostsState state) {
    switch (state.status) {
      case ProfileStatus.loading:
        return Center(child: CircularProgressIndicator());
      default:
        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<AllUsersPostsBloc>()
                .add(AllUsersPostsLoadUser(userId: state.user.id));
            return true;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.list, size: 28.0)),
                    Tab(icon: Icon(Icons.grid_on, size: 28.0)),
                  ],
                  indicatorWeight: 3.0,
                  onTap: (i) => context
                      .read<AllUsersPostsBloc>()
                      .add(ProfileToggleGridView(isGridView: i == 0)),
                ),
              ),
              state.isGridView
                  ? SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final post = state.posts[index];
                    final likedPostsState =
                        context.watch<LikedPostsCubit>().state;
                    final isLiked =
                    likedPostsState.likedPostIds.contains(post.id);
                    return PostView(
                      post: post,
                      isLiked: isLiked,
                      onLike: () {
                        if (isLiked) {
                          context
                              .read<LikedPostsCubit>()
                              .unlikePost(post: post);
                        } else {
                          context
                              .read<LikedPostsCubit>()
                              .likePost(post: post);
                        }
                      },
                    );
                  },
                  childCount: state.posts.length,
                ),
              )
                  : SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final post = state.posts[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        CommentsScreen.routeName,
                        arguments: CommentsScreenArgs(post: post),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  childCount: state.posts.length,
                ),
              )
            ],
          ),
        );
    }
  }
}