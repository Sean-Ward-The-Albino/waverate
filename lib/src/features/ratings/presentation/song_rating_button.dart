import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waverate/src/features/authentication/data/auth_repository.dart';
import 'package:waverate/src/features/music/domain/music_models.dart';
import 'package:waverate/src/features/ratings/data/rating_repository.dart';
import 'package:waverate/src/features/ratings/domain/rating_model.dart';
import 'package:waverate/src/features/ratings/presentation/rating_dialog.dart';

class SongRatingButton extends ConsumerWidget {
  final Song song;
  final double iconSize;

  const SongRatingButton({super.key, required this.song, this.iconSize = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    // Watch specifically for this song's rating by this user
    // Note: In a real app, we might optimize this to not fetch every single one individually
    // but for now, we'll fetch it on demand or setup a stream if possible.
    // The repository method getSongRating is a Future, so we can't 'watch' it easily without a FutureProvider family.
    // However, we have userRatingsProvider which streams ALL ratings.
    // Let's filter that list.
    final userRatingsProb = ref.watch(userRatingsProvider);

    return userRatingsProb.when(
      data: (ratings) {
        final rating = ratings.firstWhere(
          (r) => r.songId == song.id,
          orElse: () => Rating(
              id: '',
              userId: '',
              songId: '',
              artistId: '',
              albumId: '',
              value: -1, // Sentinel
              isFavorite: false,
              timestamp: DateTime.now()),
        );

        final hasRated = rating.value != -1;

        return IconButton(
          icon: Icon(
            hasRated ? Icons.star : Icons.star_border,
            color:
                hasRated ? Colors.amber : Theme.of(context).colorScheme.outline,
            size: iconSize,
          ),
          onPressed: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => RatingDialog(
                songTitle: song.title,
                artistName: song.artistName,
                initialRating: hasRated ? rating.value : 0.0,
                initialFavorite: hasRated ? rating.isFavorite : false,
                initialReview: hasRated ? rating.review : null,
              ),
            );

            if (result != null) {
              final newValue = result['value'] as double;
              final newFav = result['isFavorite'] as bool;
              final newReview = result['review'] as String?;

              final newRating = Rating.create(
                id: hasRated
                    ? rating.id
                    : '${user.uid}_${song.id}', // Simple ID scheme
                userId: user.uid,
                songId: song.id,
                artistId: song.artistId,
                albumId: song.albumId,
                value: newValue,
                isFavoriteOverride: newFav,
                review: newReview,
              );

              await ref.read(ratingRepositoryProvider).addRating(newRating);
            }
          },
        );
      },
      loading: () => SizedBox(
          width: iconSize,
          height: iconSize,
          child: const CircularProgressIndicator(strokeWidth: 2)),
      error: (e, __) {
        // Log error if possible, but don't show ugly icon directly
        debugPrint('Rating Error: $e');
        return Icon(Icons.star_border,
            color: Theme.of(context).disabledColor.withOpacity(0.3),
            size: iconSize);
      },
    );
  }
}
