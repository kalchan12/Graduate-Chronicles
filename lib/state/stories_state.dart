import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Story {
  final String id;
  final File? image;
  final bool isMe;
  final String name;
  final bool isLiked;
  final int views;

  Story({
    required this.id,
    this.image,
    this.isMe = false,
    this.name = 'User',
    this.isLiked = false,
    this.views = 0,
  });

  Story copyWith({
    String? id,
    File? image,
    bool? isMe,
    String? name,
    bool? isLiked,
    int? views,
  }) {
    return Story(
      id: id ?? this.id,
      image: image ?? this.image,
      isMe: isMe ?? this.isMe,
      name: name ?? this.name,
      isLiked: isLiked ?? this.isLiked,
      views: views ?? this.views,
    );
  }
}

class StoriesNotifier extends Notifier<List<Story>> {
  @override
  List<Story> build() {
    return [
      Story(id: 'me', isMe: true, name: 'Your Story', views: 5),
      Story(id: '1', name: 'Alex', views: 12),
      Story(id: '2', name: 'Sarah', views: 8),
      Story(id: '3', name: 'Jordan', views: 15),
      Story(id: '4', name: 'Priya', views: 3),
      Story(id: '5', name: 'Kenji', views: 20),
    ];
  }

  void addStory(File image) {
    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      image: image,
      isMe: true,
      name: 'Your Story',
      views: 0,
    );

    final currentList = state;
    state = [newStory, ...currentList.where((s) => s.id != 'me')];
  }

  void toggleLike(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(isLiked: !s.isLiked);
      }
      return s;
    }).toList();
  }

  void incrementViews(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(views: s.views + 1);
      }
      return s;
    }).toList();
  }
}

final storiesProvider = NotifierProvider<StoriesNotifier, List<Story>>(
  StoriesNotifier.new,
);
