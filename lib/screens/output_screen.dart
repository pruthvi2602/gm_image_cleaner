import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> _imagePaths = [
    'assets/images_dataset/i1.jpg',
    'assets/images_dataset/i3.jpeg',
    'assets/images_dataset/i4.jpeg',
    'assets/images_dataset/ig.png',
  ];

  Set<int> _selectedIndexes = {};
  
  void _deleteSelected() {
    setState(() {
      _imagePaths = [
        for (int i = 0; i < _imagePaths.length; i++)
          if (!_selectedIndexes.contains(i)) _imagePaths[i]
      ];
      _selectedIndexes.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Morning sorted successfully'),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIndexes.length == _imagePaths.length) {
        _selectedIndexes.clear(); // Deselect all
      } else {
        _selectedIndexes =
            Set<int>.from(List.generate(_imagePaths.length, (i) => i)); // Select all
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool hasSelection = _selectedIndexes.isNotEmpty;
    
    return Scaffold(
      // Remove separate appBar styling
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          hasSelection 
              ? '${_selectedIndexes.length} selected' 
              : 'Morning Sort',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white, // Ensure text is white
          ),
        ),
        elevation: 0, // Remove elevation for seamless integration
        backgroundColor: hasSelection 
            ? Colors.black.withOpacity(0.5) // Semi-transparent when in selection mode
            : Colors.transparent, // Transparent to show gradient
        leading: hasSelection 
            ? IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _selectedIndexes.clear()),
              )
            : null,
        actions: [
          if (_imagePaths.isNotEmpty && !hasSelection)
            IconButton(
              icon: Icon(Icons.wb_sunny, color: Colors.white),
              tooltip: 'Sort All',
              onPressed: _toggleSelectAll,
            ),
          if (hasSelection) ...[
            IconButton(
              icon: Icon(
                _selectedIndexes.length == _imagePaths.length
                    ? Icons.deselect
                    : Icons.select_all,
                color: Colors.white,
              ),
              tooltip: _selectedIndexes.length == _imagePaths.length
                  ? 'Deselect All'
                  : 'Select All',
              onPressed: _toggleSelectAll,
            ),
            IconButton(
              icon: Icon(Icons.check, color: Colors.white),
              tooltip: 'Sort Selected',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sort Images'),
                    content: Text(
                      'Are you ready to sort ${_selectedIndexes.length} '
                      '${_selectedIndexes.length == 1 ? 'image' : 'images'}?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('LATER'),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteSelected();
                          Navigator.pop(context);
                        },
                        child: Text('SORT NOW', 
                          style: TextStyle(
                            color: Color(0xFFFF9800) // Consistent orange color
                          )
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Container(
        // Full-screen gradient background for both states
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF121212)], // Consistent dark blue gradient
          ),
        ),
        child: _imagePaths.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 80,
                      color: Color(0xFFFF9800), // Consistent orange color
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your day is sorted!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for visibility
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No images to organize',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7), // Slightly transparent white
                      ),
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: _imagePaths.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndexes.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected
                                ? _selectedIndexes.remove(index)
                                : _selectedIndexes.add(index);
                          });
                        },
                        onLongPress: () {
                          if (!isSelected) {
                            setState(() => _selectedIndexes.add(index));
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected 
                                    ? Border.all(
                                        color: Color(0xFFFF9800), // Consistent orange color
                                        width: 3
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  _imagePaths[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF9800).withOpacity(0.3), // Consistent orange overlay
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFF9800), // Consistent orange color
                                  ),
                                  child: Icon(
                                    Icons.wb_sunny,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}