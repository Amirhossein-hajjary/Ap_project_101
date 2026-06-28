import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A simple page that lets the user choose between camera and local gallery.
/// Returns an [XFile] or null via [Navigator.pop].
class CameraOrLocalPage extends StatelessWidget {
  const CameraOrLocalPage({super.key});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (context.mounted) Navigator.pop(context, file);
    } catch (e) {
      if (context.mounted) Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Photo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  size: 72, color: theme.primaryColor),
              const SizedBox(height: 24),
              const Text(
                'How would you like to add a photo?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take a Photo'),
                  onPressed: () => _pick(context, ImageSource.camera),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _pick(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
