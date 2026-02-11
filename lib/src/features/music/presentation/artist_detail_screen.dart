import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:waverate/src/features/music/data/music_repository.dart';
import 'package:waverate/src/features/music/domain/music_models.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final String artistId;

  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicRepo = ref.watch(musicRepositoryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Artist Header (SliverAppBar)
          FutureBuilder<Artist?>(
            future: musicRepo.getArtist(artistId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverAppBar(expandedHeight: 200);
              }
              final artist = snapshot.data;
              if (artist == null) {
                return const SliverFillRemaining(
                    child: Center(child: Text('Artist not found')));
              }
              return SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    artist.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  background: Image.network(
                    artist.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // 2. Albums List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Albums',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

          FutureBuilder<List<Album>>(
            future: musicRepo.getAlbumsByArtist(artistId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()));
              }
              final albums = snapshot.data ?? [];

              if (albums.isEmpty) {
                return const SliverToBoxAdapter(
                    child: Center(child: Text('No albums found')));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final album = albums[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(album.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        album.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text('Released: ${album.releaseDate.year}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/album/${album.id}');
                      },
                    ).animate().fadeIn(delay: (50 * index).ms).slideX();
                  },
                  childCount: albums.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
