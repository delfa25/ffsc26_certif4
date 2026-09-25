import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.userId,
    required super.tags,
    required super.views,
    required super.likes,
    required super.dislikes,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    int extractReaction(dynamic reactions, String key) {
      if (reactions is Map) {
        return (reactions[key] as num?)?.toInt() ?? 0;
      } else if (reactions is num) {
        return reactions.toInt();
      }
      return 0;
    }

    return PostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 1,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: extractReaction(json['reactions'], 'likes'),
      dislikes: extractReaction(json['reactions'], 'dislikes'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'tags': tags,
      'views': views,
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
    };
  }
}
