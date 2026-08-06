import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

class PhotoImage extends StatefulWidget {
  final int imageId;
  final BoxFit fit;

  const PhotoImage({super.key, required this.imageId, this.fit = BoxFit.cover});

  @override
  State<PhotoImage> createState() => _PhotoImageState();
}

class _PhotoImageState extends State<PhotoImage> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void didUpdateWidget(covariant PhotoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageId != widget.imageId) {
      _future = _fetch();
    }
  }

  Future<Uint8List?> _fetch() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    return provider.getImageBytes(widget.imageId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
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
        return Image.memory(snapshot.data!, fit: widget.fit);
      },
    );
  }
}