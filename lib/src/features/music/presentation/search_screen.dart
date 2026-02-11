import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:waverate/src/features/music/data/music_repository.dart';
import 'package:waverate/src/features/music/domain/music_models.dart';
import 'package:waverate/src/features/ratings/presentation/song_rating_button.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<Song> _songResults = [];
  List<Artist> _artistResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _songResults = [];
        _artistResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final musicRepo = ref.read(musicRepositoryProvider);

      // Run searches in parallel
      final results = await Future.wait([
        musicRepo.searchArtists(query),
        musicRepo.searchSongs(query),
      ]);

      if (mounted) {
        setState(() {
          _artistResults = results[0] as List<Artist>;
          _songResults = results[1] as List<Song>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search songs, artists...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
          ),
          onChanged: (value) {
            _performSearch(value);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_songResults.isEmpty && _artistResults.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Start typing to search'
                            : 'No results found',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_artistResults.isNotEmpty) ...[
                      Text(
                        'Artists',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ..._artistResults.map((artist) => ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(artist.imageUrl),
                              radius: 24,
                            ),
                            title: Text(artist.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Navigate to Artist Detail (GoRouter)
                              /* 
                                  Note: We use context.push because we want to stack 
                                  this page on top of the search tab (preserving nav bar)
                                  OR we defined it as a root route in app_router.
                                  Since it's a root route with parentNavigatorKey: rootNavigatorKey,
                                  it will cover the bottom nav.
                               */
                              context.push('/artist/${artist.id}');
                            },
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (_songResults.isNotEmpty) ...[
                      Text(
                        'Songs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ..._songResults.map((song) => ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note),
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text('${song.artistName} • ${song.albumName}'),
                            trailing: SongRatingButton(song: song),
                          ).animate().fadeIn().slideX()),
                    ],
                  ],
                ),
    );
  }
}
