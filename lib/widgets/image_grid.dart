// lib/widgets/image_grid.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGrid extends StatelessWidget {
  final List<AssetEntity> photos;
  final Set<AssetEntity> selectedPhotos;
  final Function(AssetEntity) onPhotoTap;

  const ImageGrid({
    Key? key,
    required this.photos,
    required this.selectedPhotos,
    required this.onPhotoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final isSelected = selectedPhotos.contains(photo);

        return GestureDetector(
          onTap: () => onPhotoTap(photo),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              FutureBuilder<Uint8List?>(
                future: photo.thumbnailData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                },
              ),

              // Overlay
              Container(
                color: isSelected
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.transparent,
              ),

              // Checkbox
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    isSelected ? Icons.check : Icons.circle_outlined,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
