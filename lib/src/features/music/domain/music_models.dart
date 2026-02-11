class Artist {
  final String id;
  final String name;
  final String imageUrl;

  const Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class Album {
  final String id;
  final String name;
  final String artistId; // New: Link to Artist
  final String artistName;
  final String imageUrl;
  final DateTime releaseDate;

  const Album({
    required this.id,
    required this.name,
    required this.artistId,
    required this.artistName,
    required this.imageUrl,
    required this.releaseDate,
  });
}

class Song {
  final String id;
  final String title;
  final String artistId; // New: Link to Artist
  final String artistName;
  final String albumId; // New: Link to Album
  final String albumName;
  final Duration duration;
  final String imageUrl;
  final String previewUrl;

  const Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumName,
    required this.duration,
    required this.imageUrl,
    this.previewUrl = '',
  });
}
