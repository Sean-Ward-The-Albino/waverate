import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/music_models.dart';

abstract class MusicRepository {
  Future<List<Album>> getNewReleases();
  Future<List<Song>> searchSongs(String query);
  Future<List<Artist>> searchArtists(String query);
  Future<List<Song>> getTopSongs();
  Future<List<Album>> getAlbumsByArtist(String artistId);
  Future<List<Song>> getSongsByAlbum(String albumId);
  Future<Artist?> getArtist(String artistId);
  Future<Album?> getAlbum(String albumId);
}

class MockMusicRepository implements MusicRepository {
  // --- Data Definitions ---
  final List<Artist> _artists = [
    const Artist(
      id: 'a1',
      name: 'Taylor Swift',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/9/9f/Midnights_-_Taylor_Swift.png',
    ),
    const Artist(
      id: 'a2',
      name: 'Kendrick Lamar',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/5/51/Kendrick_Lamar_-_Damn.png',
    ),
    const Artist(
        id: 'a3',
        name: 'Harry Styles',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/d/d5/Harry_Styles_-_Harry%27s_House.png'),
  ];

  final List<Album> _albums = [
    Album(
      id: 'al1',
      name: 'Midnights',
      artistId: 'a1',
      artistName: 'Taylor Swift',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/9/9f/Midnights_-_Taylor_Swift.png',
      releaseDate: DateTime(2022, 10, 21),
    ),
    Album(
      id: 'al2',
      name: 'DAMN.',
      artistId: 'a2',
      artistName: 'Kendrick Lamar',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/5/51/Kendrick_Lamar_-_Damn.png',
      releaseDate: DateTime(2017, 4, 14),
    ),
    Album(
      id: 'al3',
      name: 'To Pimp a Butterfly',
      artistId: 'a2',
      artistName: 'Kendrick Lamar',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/f/f6/Kendrick_Lamar_-_To_Pimp_a_Butterfly.png',
      releaseDate: DateTime(2015, 3, 15),
    ),
    Album(
      id: 'al4',
      name: 'Harry\'s House',
      artistId: 'a3',
      artistName: 'Harry Styles',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/d/d5/Harry_Styles_-_Harry%27s_House.png',
      releaseDate: DateTime(2022, 5, 20),
    ),
  ];

  final List<Song> _songs = [
    const Song(
      id: 's1',
      title: 'Anti-Hero',
      artistId: 'a1',
      artistName: 'Taylor Swift',
      albumId: 'al1',
      albumName: 'Midnights',
      duration: Duration(minutes: 3, seconds: 20),
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/9/9f/Midnights_-_Taylor_Swift.png',
    ),
    const Song(
      id: 's2',
      title: 'HUMBLE.',
      artistId: 'a2',
      artistName: 'Kendrick Lamar',
      albumId: 'al2',
      albumName: 'DAMN.',
      duration: Duration(minutes: 2, seconds: 57),
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/5/51/Kendrick_Lamar_-_Damn.png',
    ),
    const Song(
      id: 's3',
      title: 'DNA.',
      artistId: 'a2',
      artistName: 'Kendrick Lamar',
      albumId: 'al2',
      albumName: 'DAMN.',
      duration: Duration(minutes: 3, seconds: 5),
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/5/51/Kendrick_Lamar_-_Damn.png',
    ),
    const Song(
      id: 's4',
      title: 'King Kunta',
      artistId: 'a2',
      artistName: 'Kendrick Lamar',
      albumId: 'al3',
      albumName: 'To Pimp a Butterfly',
      duration: Duration(minutes: 3, seconds: 54),
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/f/f6/Kendrick_Lamar_-_To_Pimp_a_Butterfly.png',
    ),
    const Song(
      id: 's5',
      title: 'As It Was',
      artistId: 'a3',
      artistName: 'Harry Styles',
      albumId: 'al4',
      albumName: 'Harry\'s House',
      duration: Duration(minutes: 2, seconds: 47),
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/d/d5/Harry_Styles_-_Harry%27s_House.png',
    ),
  ];

  // --- Methods ---

  @override
  Future<List<Album>> getNewReleases() async {
    await Future.delayed(const Duration(seconds: 1));
    return _albums;
  }

  @override
  Future<List<Song>> getTopSongs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _songs;
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lower = query.toLowerCase();
    if (lower.isEmpty) return [];
    return _songs
        .where((s) =>
            s.title.toLowerCase().contains(lower) ||
            s.artistName.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<Artist>> searchArtists(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lower = query.toLowerCase();
    if (lower.isEmpty) return [];
    return _artists.where((a) => a.name.toLowerCase().contains(lower)).toList();
  }

  @override
  Future<List<Album>> getAlbumsByArtist(String artistId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _albums.where((a) => a.artistId == artistId).toList();
  }

  @override
  Future<List<Song>> getSongsByAlbum(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _songs.where((s) => s.albumId == albumId).toList();
  }

  @override
  Future<Artist?> getArtist(String artistId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _artists.firstWhere((a) => a.id == artistId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Album?> getAlbum(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _albums.firstWhere((a) => a.id == albumId);
    } catch (_) {
      return null;
    }
  }
}

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MockMusicRepository();
});
