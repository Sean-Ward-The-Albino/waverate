import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waverate/src/features/authentication/data/auth_repository.dart';
import '../domain/rating_model.dart';

abstract class RatingRepository {
  Future<void> addRating(Rating rating);
  Stream<List<Rating>> getUserRatings(String userId);
  Future<Rating?> getSongRating(String userId, String songId);
}

class FirestoreRatingRepository implements RatingRepository {
  final FirebaseFirestore _firestore;

  FirestoreRatingRepository(this._firestore);

  @override
  Future<void> addRating(Rating rating) async {
    await _firestore.collection('ratings').doc(rating.id).set(rating.toMap());
  }

  @override
  Stream<List<Rating>> getUserRatings(String userId) {
    return _firestore
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        // .orderBy('timestamp', descending: true) // Requires index
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Rating.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<Rating?> getSongRating(String userId, String songId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .where('songId', isEqualTo: songId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Rating.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
    }
    return null;
  }
}

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return FirestoreRatingRepository(FirebaseFirestore.instance);
});

final userRatingsProvider = StreamProvider<List<Rating>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(ratingRepositoryProvider).getUserRatings(user.uid);
});
