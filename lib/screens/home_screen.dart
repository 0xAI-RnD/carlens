import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import 'results_screen.dart';
import 'garage_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      // Multi-photo from gallery
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        limit: 3,
      );
      if (images.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imagePath: images.first.path,
              extraImagePaths: images.length > 1
                  ? images.sublist(1).map((x) => x.path).toList()
                  : null,
            ),
          ),
        );
      }
    } else {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(imagePath: image.path),
          ),
        );
      }
    }
  }

  Future<void> _pasteLink() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text?.trim() ?? '';

    // Extract URL from text - handles cases where apps add extra text
    // e.g. "Guarda questo annuncio: https://www.subito.it/auto/..."
    final urlMatch = RegExp(r'https?://[^\s<>"]+').firstMatch(text);
    final url = urlMatch?.group(0);

    if (url != null && url.isNotEmpty) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imagePath: '',
              listingUrl: url,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nessun link valido negli appunti'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _currentIndex == 0 ? _buildScanPage() : const GarageScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(
            top: BorderSide(color: context.colors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: context.colors.background,
          selectedItemColor: context.colors.textPrimary,
          unselectedItemColor: context.colors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'Garage',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanPage() {
    return SafeArea(
      child: Stack(
        children: [
          // Settings button top-right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: context.colors.textSecondary,
                size: 22,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
          Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              Text(
                'CARLENS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 12,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'Identifica la tua classica',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 60),

              // Camera button - large circle
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surfaceCard,
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Camera icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.textPrimary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 24,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scatta una foto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Gallery link
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: context.colors.border, width: 1),
                    ),
                  ),
                  child: Text(
                    'oppure carica dalla galleria (fino a 3 foto)',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Paste link button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pasteLink,
                  icon: const Icon(Icons.link, size: 20),
                  label: const Text('Incolla Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    side: BorderSide(color: context.colors.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}
