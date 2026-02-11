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

  Future<List<AppUser>> searchUsers(String query) async {
    final lower = query.toLowerCase();
    // Note: Firestore doesn't support native partial string search efficiently without external tools (Algolia/Typesense).
    // For this MVP, we'll search by exact username or simple startAt/endAt if possible,
    // or client-side filtering if dataset is small (not scalable).
    // Better approach for MVP: usage of '>= query' and '<= query + \uf8ff' for prefix search on username.

    // We need to store a 'username_lowercase' or similar field for this to work well,
    // or assume username is always lowercase (which it seems to be).

    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: lower)
        .where('username', isLessThanOrEqualTo: '$lower\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    // 1. Add to 'following' subcollection of current user
    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .set({'timestamp': FieldValue.serverTimestamp()});

    // 2. Add to 'followers' subcollection of target user (Optional for MVP but good for counts)
    await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(currentUid)
        .set({'timestamp': FieldValue.serverTimestamp()});
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .delete();

    await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(currentUid)
        .delete();
  }

  Stream<List<String>> getFollowingIds(String currentUid) {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<List<AppUser>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    // Firestore 'in' query is limited to 10 items.
    // For MVP, if list is small, we can use 'whereIn'.
    // If large, we need to chunk it or fetch individually.
    // Let's assume < 10 for now or fetch individually.

    if (userIds.length > 10) {
      // Fallback: fetch individually
      final futures =
          userIds.map((uid) => _firestore.collection('users').doc(uid).get());
      final snapshots = await Future.wait(futures);
      return snapshots
          .where((doc) => doc.exists)
          .map((doc) => AppUser.fromMap(doc.data()!))
          .toList();
    }

    final snapshot = await _firestore
        .collection('users')
        .where('uid', whereIn: userIds)
        .get();

    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }
}

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firebaseFirestoreProvider));
});
