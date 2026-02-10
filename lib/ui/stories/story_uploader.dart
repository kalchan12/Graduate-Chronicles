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
        allowMultiple: true, // Allow multiple selection
      );

      if (result != null && result.files.isNotEmpty) {
        final List<File> filesToUpload = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();

        if (filesToUpload.isEmpty) return;

        // Show comprehensive loading toast
        if (context.mounted) {
          ToastHelper.show(
            context,
            'Uploading ${filesToUpload.length} ${filesToUpload.length == 1 ? 'story' : 'stories'}...',
          );
        }

        // Check if already uploading to prevent double submission
        final notifier = ref.read(storiesProvider.notifier);
        if (notifier.isLoading) return;

        // Batch Upload
        await notifier.uploadStories(filesToUpload);

        // Success toast
        if (context.mounted) {
          ToastHelper.show(context, 'Stories uploaded successfully!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.show(context, 'Failed to upload stories', isError: true);
      }
    }
  }
}
