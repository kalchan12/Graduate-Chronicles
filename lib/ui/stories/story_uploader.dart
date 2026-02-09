import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/stories_state.dart';
import '../widgets/toast_helper.dart';

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

        final isVideo = [
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
          'wmv',
          'flv',
          '3gp',
        ].contains(extension);
        final mediaType = isVideo ? StoryMediaType.video : StoryMediaType.image;

        // Show loading toast
        if (context.mounted) {
          ToastHelper.show(context, 'Uploading story...');
        }

        // Upload
        await ref.read(storiesProvider.notifier).uploadStory(file, mediaType);

        // Success toast
        if (context.mounted) {
          ToastHelper.show(context, 'Story uploaded!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.show(context, 'Failed to upload story', isError: true);
      }
    }
  }
}
