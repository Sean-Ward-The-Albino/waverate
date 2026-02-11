import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waverate/src/features/authentication/data/auth_repository.dart';
import 'package:waverate/src/features/authentication/data/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:waverate/src/features/authentication/domain/app_user.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Find People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FollowingTab(),
          _FindPeopleTab(),
        ],
      ),
    );
  }
}

final followingIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(userRepositoryProvider).getFollowingIds(user.uid);
});

class _FollowingTab extends ConsumerWidget {
  const _FollowingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingIdsProvider);

    return followingAsync.when(
      data: (ids) {
        if (ids.isEmpty) {
          return const Center(child: Text('You are not following anyone yet.'));
        }

        // Fetch user details for these IDs
        // Note: For optimal performance, we should cache this or use a provider family.
        // For MVP, we'll use a FutureBuilder.
        return FutureBuilder<List<AppUser>>(
          future: ref.read(userRepositoryProvider).getUsersByIds(ids),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(user.displayName ?? user.username),
                  subtitle: Text('@${user.username}'),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final currentUser =
                          ref.read(authRepositoryProvider).currentUser;
                      if (currentUser != null) {
                        await ref
                            .read(userRepositoryProvider)
                            .unfollowUser(currentUser.uid, user.uid);
                      }
                    },
                    child: const Text('Unfollow'),
                  ),
                  onTap: () {
                    // Navigate to User Profile (Phase 5b)
                    // context.push('/profile/${user.uid}');
                  },
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

class _FindPeopleTab extends ConsumerStatefulWidget {
  const _FindPeopleTab();

  @override
  ConsumerState<_FindPeopleTab> createState() => _FindPeopleTabState();
}

class _FindPeopleTabState extends ConsumerState<_FindPeopleTab> {
  final _searchController = TextEditingController();
  List<AppUser> _results = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final users = await ref.read(userRepositoryProvider).searchUsers(query);
      setState(() => _results = users);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final followingIdsAsync = ref.watch(followingIdsProvider);
    final followingIds = followingIdsAsync.value ?? [];
    final currentUser = ref.watch(authRepositoryProvider).currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Users',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              helperText: 'Search by username',
            ),
            onSubmitted: _search,
            textInputAction: TextInputAction.search,
          ),
        ),
        if (_isLoading)
          const LinearProgressIndicator()
        else
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final user = _results[index];
                final isMe = user.uid == currentUser?.uid;
                final isFollowing = followingIds.contains(user.uid);

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(user.displayName ?? user.username),
                  subtitle: Text('@${user.username}'),
                  trailing: isMe
                      ? const SizedBox.shrink()
                      : isFollowing
                          ? OutlinedButton(
                              onPressed: () async {
                                if (currentUser != null) {
                                  await ref
                                      .read(userRepositoryProvider)
                                      .unfollowUser(currentUser.uid, user.uid);
                                }
                              },
                              child: const Text('Unfollow'),
                            )
                          : FilledButton(
                              onPressed: () async {
                                if (currentUser != null) {
                                  await ref
                                      .read(userRepositoryProvider)
                                      .followUser(currentUser.uid, user.uid);
                                }
                              },
                              child: const Text('Follow'),
                            ),
                  onTap: () {
                    // Navigate to User Profile
                    context.push(
                        '/user/${user.uid}?username=${Uri.encodeComponent(user.username)}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
