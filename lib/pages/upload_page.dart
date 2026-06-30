import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/pressable.dart';
import '../services/auth_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _captionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  File? _selectedImage;
  String _selectedAlbum = 'Default';
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          if (_nameController.text.isEmpty) {
            _nameController.text = 'Image_${DateTime.now().millisecondsSinceEpoch % 10000}';
          }
        });
      }
    } catch (e) {
      AuthService.showToast('Error picking image: $e', isError: true);
    }
  }

  void _upload() {
    if (_selectedImage == null) {
      AuthService.showToast('Please select an image first', isError: true);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GalleryProvider>(context, listen: false);
      
      final newPhoto = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text,
        'image': _selectedImage!.path,
        'album': _selectedAlbum, // For backwards compatibility if any
        'albums': [_selectedAlbum], // New requirement: list of albums
        'date': DateTime.now(),
        'isLocal': true,
        'isFavorite': false,
        'caption': _captionController.text,
        'tags': _tagsController.text,
        'captions': _captionController.text.isNotEmpty ? [_captionController.text] : [],
        'comments': [],
        'allowComments': true,
      };

      try {
        provider.addPhoto(newPhoto);
        AuthService.showToast('Image uploaded successfully!');
        Navigator.pop(context);
      } catch (e) {
        AuthService.showToast('Upload failed: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<GalleryProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('UPLOAD IMAGE'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withAlpha(200)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview Section
                  Center(
                    child: Pressable(
                      onTap: () => _showPickerOptions(),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: theme.primaryColor.withAlpha(50), width: 2),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 64, color: theme.primaryColor),
                                  const SizedBox(height: 12),
                                  Text('Tap to select or capture', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fields Section
                  const Text('Mandatory Information', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          label: 'Image Name *',
                          hint: 'Enter image title',
                          icon: Icons.title_rounded,
                          validator: (v) => v!.isEmpty ? 'Image name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Album Selection
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text('Album *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('Default'),
                                  selected: _selectedAlbum == 'Default',
                                  onSelected: (v) => setState(() => _selectedAlbum = 'Default'),
                                ),
                                ...provider.userAlbums.map((a) => ChoiceChip(
                                  label: Text(a),
                                  selected: _selectedAlbum == a,
                                  onSelected: (v) => setState(() => _selectedAlbum = a),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Additional Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.grey)),
                  const SizedBox(height: 16),

                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _captionController,
                          label: 'Caption',
                          hint: 'Write a description...',
                          icon: Icons.notes_rounded,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _tagsController,
                          label: 'Tags',
                          hint: 'e.g. travel, nature, friends',
                          icon: Icons.tag_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  Pressable(
                    onTap: _upload,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: theme.primaryColor.withAlpha(100), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Upload to Cloud',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
              title: const Text('Open Gallery', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
