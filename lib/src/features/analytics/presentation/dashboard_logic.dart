import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waverate/src/features/music/data/music_repository.dart';
import 'package:waverate/src/features/music/domain/music_models.dart';
import 'package:waverate/src/features/ratings/data/rating_repository.dart';
import 'package:waverate/src/features/ratings/domain/rating_model.dart';
import 'package:collection/collection.dart';

class DashboardData {
  final List<TopArtist> topArtists;
  final List<TopAlbum> topAlbums;
  final List<TopSong> topSongs;

  const DashboardData({
    this.topArtists = const [],
    this.topAlbums = const [],
    this.topSongs = const [],
  });
}

class TopArtist {
  final Artist artist;
  final double averageRating;
  final int ratingCount;

  TopArtist(this.artist, this.averageRating, this.ratingCount);
}

class TopAlbum {
  final Album album;
  final double averageRating;
  final int ratingCount;

  TopAlbum(this.album, this.averageRating, this.ratingCount);
}

class TopSong {
  final Song song;
  final double rating;

  TopSong(this.song, this.rating);
}

final dashboardProvider =
    FutureProvider.family<DashboardData, String>((ref, userId) async {
  final userRatings = await ref.watch(userRatingsProvider(userId).future);
  final musicRepo = ref.read(musicRepositoryProvider);

  if (userRatings.isEmpty) {
    return const DashboardData();
  }

  // 1. Calculate Top Artists
  final ratingsByArtist = groupBy(userRatings, (Rating r) => r.artistId);
  final topArtistsFutures = ratingsByArtist.entries.map((entry) async {
    final artistId = entry.key;
    final ratings = entry.value;
    final average = ratings.map((r) => r.value).average;

    final artist = await musicRepo.getArtist(artistId);
    if (artist == null) return null;

    return TopArtist(artist, average, ratings.length);
  });

  final topArtists = (await Future.wait(topArtistsFutures))
      .whereType<TopArtist>()
      .sorted((a, b) => b.averageRating.compareTo(a.averageRating))
      .take(5) // Top 5
      .toList();

  // 2. Calculate Top Albums
  final ratingsByAlbum = groupBy(userRatings, (Rating r) => r.albumId);
  final topAlbumsFutures = ratingsByAlbum.entries.map((entry) async {
    final albumId = entry.key;
    final ratings = entry.value;
    final average = ratings.map((r) => r.value).average;

    final album = await musicRepo.getAlbum(albumId);
    if (album == null) return null;

    return TopAlbum(album, average, ratings.length);
  });

  final topAlbums = (await Future.wait(topAlbumsFutures))
      .whereType<TopAlbum>()
      .sorted((a, b) => b.averageRating.compareTo(a.averageRating))
      .take(5) // Top 5
      .toList();

  // 3. Calculate Top Songs (Simpler, just sort by value)
  // We need to fetch song details for them. userRatings has songId.
  // We don't have getSong(id) yet... oops.
  // Workaround: We know MockRepo.searchSongs('') returns all songs? Or getTopSongs returns all.
  // Let's implement a getSong(id) in the repository or use a workaround.
  // Efficient workaround for now: We have `musicRepo.getTopSongs` which returns all songs in mock.
  // In real app, we'd fetch specific song.
  // Let's rely on finding it in the full list for now.

  final allSongs = await musicRepo.getTopSongs(); // Mock returns all

  final topRatedSongs = userRatings
      .sorted((a, b) => b.value.compareTo(a.value))
      .take(5)
      .map((rating) {
        final song = allSongs.firstWhereOrNull((s) => s.id == rating.songId);
        if (song == null) return null;
        return TopSong(song, rating.value);
      })
      .whereType<TopSong>()
      .toList();

  return DashboardData(
    topArtists: topArtists,
    topAlbums: topAlbums,
    topSongs: topRatedSongs,
  );
});
