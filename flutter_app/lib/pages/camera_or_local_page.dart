import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_theme.dart';
import '../widgets/glass_container.dart';

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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Add Photo')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [AppTheme.darkBg, AppTheme.darkSurface]
                : [AppTheme.lightBg, AppTheme.lightBg.withAlpha(220)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: GlassContainer(
              borderRadius: AppTheme.radiusXl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2Xl),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_a_photo_rounded, size: 64, color: theme.primaryColor),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  Text(
                    'Capture or Choose',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Pick a source to add a new memory',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing3Xl),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('TAKE A PHOTO'),
                    onPressed: () => _pick(context, ImageSource.camera),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('CHOOSE FROM GALLERY'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      side: BorderSide(color: theme.primaryColor.withAlpha(100)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    onPressed: () => _pick(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
