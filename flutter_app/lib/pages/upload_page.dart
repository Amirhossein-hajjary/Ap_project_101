import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';
import '../widgets/pressable.dart';
import '../themes/app_theme.dart';
import 'dart:convert';

class UploadPage extends StatefulWidget {
  final XFile? initialImage;
  const UploadPage({super.key, this.initialImage});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _objectsController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  
  final List<String> _selectedAlbums = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _imageFile = File(widget.initialImage!.path);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _captionController.dispose();
    _objectsController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null) {
        setState(() {
          _imageFile = File(file.path);
        });
      }
    } catch (e) {
      AuthService.showToast('Failed to pick image', isError: true);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitUpload() async {
    if (_imageFile == null) {
      AuthService.showToast('Please select an image first', isError: true);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      try {
        final bytes = await _imageFile!.readAsBytes();
        final String base64Data = base64Encode(bytes);

        final provider = Provider.of<GalleryProvider>(context, listen: false);

        final success = await provider.addPhoto({
          'name': _titleController.text,
          'caption': _captionController.text,
          'albums': List<String>.from(_selectedAlbums),
          'tags': _tagsController.text,
          'base64Data': base64Data,
        });

        if (success) {
          AuthService.showToast('Image uploaded successfully');
          if (mounted) Navigator.pop(context);
        } else {
          AuthService.showToast('Failed to upload image', isError: true);
        }
      } catch (e) {
        AuthService.showToast('Failed to upload image', isError: true);
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: AppTheme.radiusXl,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Source', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.lightText
              )
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded, 
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.lightText
              ),
              title: Text(
                'Open Gallery', 
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.lightText)
              ),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_rounded, 
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.lightText
              ),
              title: Text(
                'Take Photo', 
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.lightText)
              ),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final galleryProvider = Provider.of<GalleryProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Pressable(
                    onTap: _showPickerOptions,
                    child: Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withAlpha(theme.brightness == Brightness.dark ? 10 : 5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: theme.primaryColor.withAlpha(theme.brightness == Brightness.dark ? 20 : 40), 
                          width: 2
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg - 2),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded, 
                                  size: 48, 
                                  color: theme.brightness == Brightness.dark 
                                    ? theme.primaryColor.withAlpha(150) 
                                    : theme.primaryColor
                                ),
                                const SizedBox(height: AppTheme.spacingMd),
                                Text(
                                  'Select or Capture', 
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.brightness == Brightness.dark 
                                      ? theme.primaryColor.withAlpha(150) 
                                      : theme.primaryColor
                                  )
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2Xl),

                CustomTextField(
                  controller: _titleController,
                  label: 'Title *',
                  hint: 'Memory title',
                  icon: Icons.title_rounded,
                  validator: (value) => (value == null || value.isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                Text('Associated Albums', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppTheme.spacingMd),
                if (galleryProvider.userAlbums.isEmpty)
                  Text('No albums created yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))
                else
                  Wrap(
                    spacing: AppTheme.spacingSm,
                    runSpacing: AppTheme.spacingSm,
                    children: galleryProvider.userAlbums.map((album) {
                      final isSelected = _selectedAlbums.contains(album);
                      return FilterChip(
                        label: Text(album),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAlbums.add(album);
                            } else {
                              _selectedAlbums.remove(album);
                            }
                          });
                        },
                        selectedColor: theme.primaryColor.withAlpha(30),
                        checkmarkColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: AppTheme.spacingXl),

                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date *',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                CustomTextField(
                  controller: _tagsController,
                  label: 'Tags',
                  hint: 'e.g. nature, family',
                  icon: Icons.tag_rounded,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                CustomTextField(
                  controller: _captionController,
                  label: 'Caption',
                  hint: 'Describe the moment...',
                  icon: Icons.description_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                CustomTextField(
                  controller: _objectsController,
                  label: 'Objects / Individuals',
                  hint: 'Who or what is in the photo?',
                  icon: Icons.category_rounded,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                CustomTextField(
                  controller: _categoriesController,
                  label: 'Categories',
                  hint: 'e.g. Travel, Work',
                  icon: Icons.label_important_rounded,
                ),
                const SizedBox(height: AppTheme.spacing3Xl),

                ElevatedButton(
                  onPressed: _isUploading ? null : _submitUpload,
                  child: _isUploading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('UPLOAD TO GALLERY'),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
