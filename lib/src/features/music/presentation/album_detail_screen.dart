import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waverate/src/features/music/data/music_repository.dart';
import 'package:waverate/src/features/music/domain/music_models.dart';
import 'package:waverate/src/features/ratings/presentation/song_rating_button.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicRepo = ref.watch(musicRepositoryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Album Header
          FutureBuilder<Album?>(
            future: musicRepo.getAlbum(albumId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverAppBar(expandedHeight: 200);
              }
              final album = snapshot.data;
              if (album == null) {
                return const SliverFillRemaining(
                    child: Center(child: Text('Album not found')));
              }
              return SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    album.name,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        album.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Rate Album coming soon!')),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          // 2. Tracklist
          FutureBuilder<List<Song>>(
            future: musicRepo.getSongsByAlbum(albumId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()));
              }
              final songs = snapshot.data ?? [];

              if (songs.isEmpty) {
                return const SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No songs found')),
                ));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(formatDuration(song.duration)),
                      trailing: SongRatingButton(song: song),
                      onTap: () {
                        // Play song snippet
                      },
                    ).animate().fadeIn(delay: (30 * index).ms).slideX();
                  },
                  childCount: songs.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add to Catalog
        },
        icon: const Icon(Icons.add),
        label: const Text('Add to Catalog'),
      ),
    );
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${d.inMinutes}:$twoDigitSeconds";
  }
}
