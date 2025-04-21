import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:photo_manager/photo_manager.dart';
import '../models/classifier.dart';
import '../widgets/image_grid.dart';
import '../widgets/loading_indicator.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImageClassifier _classifier = ImageClassifier();
  final List<AssetEntity> _allPhotos = [];
  final List<AssetEntity> _goodMorningPhotos = [];
  final Set<AssetEntity> _selectedPhotos = {};
  bool _isLoading = true;
  bool _isScanning = false;
  int _processedImages = 0;
  int _totalImages = 0;
  bool _isModelLoaded = false;
  String _currentAlbum = 'All Photos';
  List<AssetPathEntity> _albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
    });

    if (kIsWeb) {
      // For web, we'll just show a demo UI
      setState(() {
        _isLoading = false;
        _isScanning = false;
      });
      return;
    }

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);

    if (albums.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _albums = albums;
    });

    await _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (kIsWeb) {
      // For web, we'll just show a demo UI
      setState(() {
        _isLoading = false;
        _isScanning = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _allPhotos.clear();
      _goodMorningPhotos.clear();
    });

    try {
      if (_currentAlbum == 'All Photos') {
        for (final album in _albums) {
          final assets = await album.getAssetListRange(start: 0, end: 10000);
          _allPhotos.addAll(assets);
        }
      } else {
        final selectedAlbum = _albums.firstWhere(
          (album) => album.name == _currentAlbum,
          orElse: () => _albums.first,
        );
        final assets =
            await selectedAlbum.getAssetListRange(start: 0, end: 10000);
        _allPhotos.addAll(assets);
      }

      setState(() {
        _totalImages = _allPhotos.length;
        _isScanning = true;
      });

      // For UI demo, just use the first 20 images
      setState(() {
        _goodMorningPhotos.addAll(_allPhotos.take(20));
        _isScanning = false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading photos: $e');
      setState(() {
        _isLoading = false;
        _isScanning = false;
      });
    }
  }

  void _togglePhotoSelection(AssetEntity photo) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
      } else {
        _selectedPhotos.add(photo);
      }
    });
  }

  Future<void> _deleteSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Images'),
        content: Text(
            'Are you sure you want to delete ${_selectedPhotos.length} images?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      // Convert to List because we're modifying _selectedPhotos during iteration
      final photosToDelete = _selectedPhotos.toList();

      for (final photo in photosToDelete) {
        final result = await PhotoManager.editor.deleteWithIds([photo.id]);

        if (result == true && mounted) {
          setState(() {
            _goodMorningPhotos.remove(photo);
            _selectedPhotos.remove(photo);
          });
        }
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${photosToDelete.length} images deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _selectAll() {
    setState(() {
      if (_selectedPhotos.length == _goodMorningPhotos.length) {
        // Deselect all if all are selected
        _selectedPhotos.clear();
      } else {
        // Select all
        _selectedPhotos.addAll(_goodMorningPhotos);
      }
    });
  }

  void _showAlbumSelector() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Album selection is not available in web mode'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Album',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _albums.length + 1, // +1 for "All Photos"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('All Photos'),
                      selected: _currentAlbum == 'All Photos',
                      onTap: () {
                        setState(() {
                          _currentAlbum = 'All Photos';
                        });
                        Navigator.pop(context);
                        _loadPhotos();
                      },
                    );
                  }

                  final album = _albums[index - 1];
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(album.name),
                    subtitle: FutureBuilder<int>(
                      future: album.assetCountAsync,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('${snapshot.data} photos');
                        }
                        return const Text('Loading...');
                      },
                    ),
                    selected: _currentAlbum == album.name,
                    onTap: () {
                      setState(() {
                        _currentAlbum = album.name;
                      });
                      Navigator.pop(context);
                      _loadPhotos();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning Images'),
        actions: [
          if (!_isScanning && _goodMorningPhotos.isNotEmpty)
            IconButton(
              icon: Icon(
                _selectedPhotos.length == _goodMorningPhotos.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              onPressed: _selectAll,
              tooltip: _selectedPhotos.length == _goodMorningPhotos.length
                  ? 'Deselect All'
                  : 'Select All',
            ),
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: _showAlbumSelector,
            tooltip: 'Select Album',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _isScanning || _goodMorningPhotos.isEmpty
          ? null
          : BottomAppBar(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedPhotos.length} selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        if (_selectedPhotos.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            onPressed: () {
                              // Share functionality would go here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Share functionality coming soon'),
                                ),
                              );
                            },
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _selectedPhotos.isEmpty
                              ? null
                              : _deleteSelectedPhotos,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.web,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Web Mode',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This app requires native device access for photo management. Please use the mobile app for full functionality.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading && !_isScanning) {
      return const LoadingIndicator(message: 'Loading images...');
    }

    if (_isScanning) {
      final progress = _totalImages > 0 ? _processedImages / _totalImages : 0.0;
      return LoadingIndicator(
        message: 'Scanning images: $_processedImages / $_totalImages',
        progress: progress,
      );
    }

    if (_goodMorningPhotos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'No "Good Morning" images found!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your device seems to be free of typical "Good Morning" images.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: _loadPhotos,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.folder, size: 16),
              const SizedBox(width: 8),
              Text(
                _currentAlbum,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_goodMorningPhotos.length} images',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ImageGrid(
            photos: _goodMorningPhotos,
            selectedPhotos: _selectedPhotos,
            onPhotoTap: _togglePhotoSelection,
          ),
        ),
      ],
    );
  }
}
