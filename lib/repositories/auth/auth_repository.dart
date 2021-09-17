import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twitter_glsample/config/paths.dart';
import 'package:flutter_twitter_glsample/models/failure_model.dart';
import 'package:flutter_twitter_glsample/repositories/auth/base_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthRepository extends BaseAuthRepository {
  final FirebaseFirestore _firebaseFirestore;
  final auth.FirebaseAuth _fireBaseAuth;

  AuthRepository(
      {FirebaseFirestore firebaseFirestore, auth.FirebaseAuth fireBaseAuth})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
        _fireBaseAuth = fireBaseAuth ?? auth.FirebaseAuth.instance;

  @override
  // Updates changes to the firebase user
  Stream<auth.User> get user => _fireBaseAuth.userChanges();

  @override
  Future<auth.User> signUpWithEmailAndPassword(
      {@required String username, @required String email, @required String password}) async {
    try {
      final credential = await _fireBaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user;
      _firebaseFirestore.collection(Paths.users).doc(user.uid).set({
        'username': username,
        'email': email,
        'followers': 0,
        'following': 0,
      });
      return user;
    } on auth.FirebaseException catch (err) {
      throw Failure(code: err.code, message: err.message);
    }
    on PlatformException catch (err) {
      throw Failure(code: err.code, message: err.message);
    }
  }

  @override
  Future<auth.User> logInWithEmailAndPassword(
      {@required String email, @required String password}) async {
    try {
      final credential = await _fireBaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on auth.FirebaseException catch (err) {
      throw Failure(code: err.code, message: err.message);
    }
    on PlatformException catch (err) {
      throw Failure(code: err.code, message: err.message);
    }
  }

  @override
  Future<void> logOut() async {
    // Logout user
    await _fireBaseAuth.signOut();
  }
}
