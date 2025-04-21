import 'package:flutter/material.dart';
import 'output_screen.dart';

class HomeScreen extends StatelessWidget {
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.wb_sunny, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 10),
            Text('Morning Permission'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Morning Sort needs access to your photos to help you organize your day.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Would you like to start your day with Morning Sort?',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('LATER', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => GalleryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('START'),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      // Remove the appBar completely to integrate the header with the screen
      extendBodyBehindAppBar: true,
      body: Container(
        // Full-screen gradient that applies to the entire screen including where the header was
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Color(0xFF1A237E), Color(0xFF121212)]
                : [Color(0xFF87CEEB), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMorningLogo(isDark),
                SizedBox(height: 40),
                Text(
                  'Morning Sort',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    // Ensure text is visible against the background
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Start your day right by organizing your moments',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      // Light text color for better visibility
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                SizedBox(height: 60),
                ElevatedButton.icon(
                  onPressed: () => _showPermissionDialog(context),
                  icon: Icon(Icons.wb_sunny),
                  label: Text('START YOUR DAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800), // Orange button to match the sun
                    foregroundColor: Colors.black, // Black text for contrast
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMorningLogo(bool isDark) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[800], // Darker background for logo container
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sun rays
          for (var i = 0; i < 8; i++)
            Positioned(
              child: Transform.rotate(
                angle: i * 3.14159 / 4, // 45-degree spacing
                child: Container(
                  width: 150,
                  height: 20,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF9800), // Consistent orange color
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Sun center
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFFF9800), // Consistent orange color
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}