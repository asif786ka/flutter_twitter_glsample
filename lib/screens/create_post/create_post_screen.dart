import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_twitter_glsample/blocs/auth/auth_bloc.dart';
import 'package:flutter_twitter_glsample/helpers/image_helper.dart';
import 'package:flutter_twitter_glsample/screens/allusers_posts/allusers_posts_screen.dart';
import 'package:flutter_twitter_glsample/screens/profile/profile_screen.dart';
import 'package:flutter_twitter_glsample/widgets/error_dialog.dart';
import 'package:image_cropper/image_cropper.dart';

import 'cubit/create_post_cubit.dart';

class CreatePostScreen extends StatelessWidget {
  static const String routeName = '/createPost';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
          titleSpacing: 10.0,
          centerTitle: true,
          title: const Text('Create Post'),
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state.status == CreatePostStatus.success) {
              _formKey.currentState.reset();
              context.read<CreatePostCubit>().reset();

              Scaffold.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                  content: const Text('Post Created'),
                ),
              );

              //Take the user to profile screen to see the posts in gridview or listview.
              Navigator.of(context).pushNamed(
                AllUsersPostsScreen.routeName,
                arguments: AllUsersPostsScreenArgs(userId: context.read<AuthBloc>().state.user.uid),
              );
            } else if (state.status == CreatePostStatus.error) {
              showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _selectPostImage(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: state.postImage != null
                          ? Image.file(state.postImage, fit: BoxFit.cover)
                          : const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 120.0,
                      ),
                    ),
                  ),
                  if (state.status == CreatePostStatus.submitting)
                    const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(hintText: 'Caption'),
                            onChanged: (value) => context
                                .read<CreatePostCubit>()
                                .captionChanged(value),
                            validator: (value) => value.trim().isEmpty
                                ? 'Caption cannot be empty.'
                                : null,
                          ),
                          const SizedBox(height: 28.0),
                          RaisedButton(
                            elevation: 1.0,
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            onPressed: () => _submitForm(
                              context,
                              state.postImage,
                              state.status == CreatePostStatus.submitting,
                            ),
                            child: const Text('Post'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectPostImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Create Post',
    );
    if (pickedFile != null) {
      context.read<CreatePostCubit>().postImageChanged(pickedFile);
    }
  }

  void _submitForm(BuildContext context, File postImage, bool isSubmitting) {
    if (_formKey.currentState.validate() &&
        postImage != null &&
        !isSubmitting) {
      context.read<CreatePostCubit>().submit();
    } else {
      context.read<CreatePostCubit>().emptyImageOrText();
    }
  }
}
