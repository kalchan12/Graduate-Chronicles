import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Story {
  final String id;
  final File? image;
  final bool isMe;
  final String name;

  Story({required this.id, this.image, this.isMe = false, this.name = 'User'});
}

class StoriesNotifier extends Notifier<List<Story>> {
  @override
  List<Story> build() {
    return [
      Story(id: 'me', isMe: true, name: 'Your Story'),
      Story(id: '1', name: 'Alex'),
      Story(id: '2', name: 'Sarah'),
      Story(id: '3', name: 'Jordan'),
      Story(id: '4', name: 'Priya'),
      Story(id: '5', name: 'Kenji'),
    ];
  }

  void addStory(File image) {
    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      image: image,
      isMe: true,
      name: 'Your Story',
    );

    // Replace the existing placeholder or add a new one
    final currentList = state;
    state = [newStory, ...currentList.where((s) => s.id != 'me')];
  }
}

final storiesProvider = NotifierProvider<StoriesNotifier, List<Story>>(
  StoriesNotifier.new,
);
