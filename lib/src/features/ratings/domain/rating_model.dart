import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String userId;
  final String songId;
  final String artistId;
  final String albumId;
  final double value; // 0.0 to 10.0, 0.25 increments
  final bool isFavorite;
  final String? review;
  final DateTime timestamp;

  const Rating({
    required this.id,
    required this.userId,
    required this.songId,
    required this.artistId,
    required this.albumId,
    required this.value,
    required this.isFavorite,
    this.review,
    required this.timestamp,
  });

  // Factory to create a new rating with auto-favorite logic
  factory Rating.create({
    required String id,
    required String userId,
    required String songId,
    required String artistId,
    required String albumId,
    required double value,
    bool? isFavoriteOverride,
    String? review,
  }) {
    // Default favorite threshold is 8.0
    final isFav = isFavoriteOverride ?? (value >= 8.0);

    return Rating(
      id: id,
      userId: userId,
      songId: songId,
      artistId: artistId,
      albumId: albumId,
      value: value,
      isFavorite: isFav,
      review: review,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'songId': songId,
      'artistId': artistId,
      'albumId': albumId,
      'value': value,
      'isFavorite': isFavorite,
      'review': review,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Rating.fromMap(String id, Map<String, dynamic> map) {
    return Rating(
      id: id,
      userId: map['userId'] ?? '',
      songId: map['songId'] ?? '',
      artistId: map['artistId'] ?? '',
      albumId: map['albumId'] ?? '',
      value: (map['value'] as num).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
      review: map['review'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
