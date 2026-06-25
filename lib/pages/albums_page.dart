import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // استفاده از تصاویر با کیفیت که در ایران معمولاً بدون فیلتر در دسترس هستند
    final List<Map<String, dynamic>> albums = [
      {
        'title': 'Nature & Mountains',
        'count': '1,240',
        'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=500'
      },
      {
        'title': 'Modern Architecture',
        'count': '452',
        'image': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=500'
      },
      {
        'title': 'Ocean & Blue',
        'count': '891',
        'image': 'https://images.unsplash.com/photo-1505118380757-91f5f45d8de4?auto=format&fit=crop&q=80&w=500'
      },
      {
        'title': 'Forest Secrets',
        'count': '125',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&q=80&w=500'
      },
      {
        'title': 'Night Cityscape',
        'count': '342',
        'image': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&q=80&w=500'
      },
      {
        'title': 'Abstract Art',
        'count': '670',
        'image': 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?auto=format&fit=crop&q=80&w=500'
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.blackDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ALBUMS',
          style: TextStyle(
            color: AppTheme.goldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.blackDark,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) => _buildAlbumCard(albums[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.goldColor,
        onPressed: () {},
        child: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.blackDark),
      ),
    );
  }

  Widget _buildAlbumCard(Map<String, dynamic> album) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // نمایش تصویر با لودینگ در صورت کندی اینترنت
            Positioned.fill(
              child: Image.network(
                album['image'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.white10,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.goldColor,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.white24, size: 40),
                  );
                },
              ),
            ),

            // گرادینت تیره پایین کارت
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            // آیکون بالای کارت
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.collections, color: AppTheme.goldColor, size: 16),
              ),
            ),

            // اطلاعات پایین کارت
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album['count']} Photos',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),

            // افکت لمس
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  splashColor: AppTheme.goldColor.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
