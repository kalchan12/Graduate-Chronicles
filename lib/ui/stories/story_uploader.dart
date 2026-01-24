import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/stories_state.dart';

class StoryUploader {
  final WidgetRef ref;
  final BuildContext context;

  StoryUploader(this.context, this.ref);

  Future<void> pickAndUpload() async {
    try {
      // Pick file (Image or Video)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        final isVideo = ['mp4', 'mov', 'avi'].contains(extension);
        final mediaType = isVideo ? StoryMediaType.video : StoryMediaType.image;

        // Show loading indicator
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploading story...'),
              duration: Duration(days: 1),
            ),
          );
        }

        // Upload
        await ref.read(storiesProvider.notifier).uploadStory(file, mediaType);

        // Success
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Story uploaded!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload story: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
