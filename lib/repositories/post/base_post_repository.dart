import 'package:flutter_twitter_glsample/models/models.dart';
import 'package:flutter_twitter_glsample/models/post_model.dart';

abstract class BasePostRepository {
  Future<void> createPost({Post post});
  Future<void> createComment({Comment comment});
  void createLike({Post post, String userId});
  Stream<List<Future<Post>>> getUserPosts({String userId});
  Stream<List<Future<Post>>> getAllUserPosts({String userId});
  Stream<List<Future<Comment>>> getPostComments({String postId});
  Future<List<Post>> getUserFeed({String userId, String lastPostId});
  Future<Set<String>> getLikedPostIds({String userId, List<Post> posts});
  void deleteLike({String postId, String userId});
}