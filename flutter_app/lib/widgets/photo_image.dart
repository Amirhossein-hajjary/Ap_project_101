import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import 'dart:typed_data';

class PhotoImage extends StatelessWidget {
  final int imageId;
  final BoxFit fit;

  const PhotoImage({super.key, required this.imageId, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GalleryProvider>(context, listen: false);

    return FutureBuilder<Uint8List?>(
      future: provider.getImageBytes(imageId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(color: Colors.grey.withAlpha(40));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            color: Colors.grey.withAlpha(40),
            child: const Icon(Icons.broken_image_outlined),
          );
        }
        return Image.memory(snapshot.data!, fit: fit);

      },
    );
  }
}