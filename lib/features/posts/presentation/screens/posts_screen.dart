import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PostProvider>();
      if (provider.state == PostState.initial) {
        _loadPosts(provider);
      }
    });
  }

  void _loadPosts(PostProvider provider) async {
    await provider.fetchPosts();
    if (!mounted) return;
    if (provider.state == PostState.error) {
      _showErrorSnackBar(provider);
    } else if (provider.isCached && provider.userNotification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.userNotification!),
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(PostProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? 'Erreur lors du chargement des articles'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: () => _loadPosts(provider),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();

    return Scaffold(
      body: Column(
        children: [
          // Offline Banner
          if (provider.isCached && provider.state == PostState.loaded)
            Container(
              width: double.infinity,
              color: Colors.amber.shade900,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode hors-ligne : Articles affichés depuis le cache local Hive',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.fetchPosts(showLoading: false);
                if (mounted && provider.state == PostState.error) {
                  _showErrorSnackBar(provider);
                }
              },
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PostProvider provider) {
    if (provider.state == PostState.loading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == PostState.error && provider.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage ?? 'Une erreur est survenue lors du chargement des articles',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadPosts(provider),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.posts.isEmpty) {
      return const Center(
        child: Text('Aucun article trouvé'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.posts.length,
      itemBuilder: (context, index) {
        final post = provider.posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Tags chips
                if (post.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6750A4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const Divider(height: 24),

                // Stats footer
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('${post.likes}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const Icon(Icons.thumb_down_alt_outlined, size: 18, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${post.dislikes}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.views} vues', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
