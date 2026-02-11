import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<bool> checkUsernameAvailable(String username) async {
    final doc = await _firestore.collection('usernames').doc(username).get();
    return !doc.exists;
  }

  Future<void> createUserProfile(AppUser user) async {
    final batch = _firestore.batch();

    // 1. Create user document
    final userRef = _firestore.collection('users').doc(user.uid);
    batch.set(userRef, user.toMap());

    // 2. Reserve username
    final usernameRef = _firestore.collection('usernames').doc(user.username);
    batch.set(usernameRef, {'uid': user.uid});

    await batch.commit();
  }
}

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firebaseFirestoreProvider));
});
