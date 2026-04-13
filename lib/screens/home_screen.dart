import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../i18n/strings.g.dart';
import '../theme/app_colors.dart';
import '../widgets/photo_tips_card.dart';
import 'achievements_placeholder_screen.dart';
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
    final urlMatch = RegExp(r'https?://[^\s<>"]+').firstMatch(text);
    final url = urlMatch?.group(0);

    if (url != null && url.isNotEmpty) {
      if (mounted) {
        final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
        String message;
        if (host.contains('subito.it')) {
          message = t.home.analyzingSubito;
        } else if (host.contains('autoscout24')) {
          message = t.home.analyzingAutoScout;
        } else {
          message = t.home.analyzingLink;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.storefront, color: context.colors.teal, size: 20),
                const SizedBox(width: 8),
                Text(message),
              ],
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: context.colors.surfaceCard,
          ),
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(imagePath: '', listingUrl: url),
              ),
            );
          }
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.home.noValidLink),
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
      body: [
        _buildScanPage(),
        const GarageScreen(),
        const AchievementsPlaceholderScreen(),
      ][_currentIndex],
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
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: t.nav.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car_outlined),
              activeIcon: const Icon(Icons.directions_car),
              label: t.nav.garage,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events_outlined),
              activeIcon: const Icon(Icons.emoji_events),
              label: t.nav.achievements,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanPage() {
    return _buildVariantHeroVisivo();
  }

  Widget _buildVariantHeroVisivo() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero area with surfaceWarm background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.surfaceWarm,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Settings row (right-aligned)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: context.colors.textSecondary,
                          size: 22,
                        ),
                        onPressed: () => _navigateToSettings(),
                      ),
                    ),
                  ),

                  // Logo + tagline in hero
                  const SizedBox(height: 24),
                  Text(
                    t.app.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 12,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.app.tagline,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),

            // Overlapping action card
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Camera button — large circle
                      Semantics(
                        label: t.home.takePhoto,
                        child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            width: 200,
                            height: 200,
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
                                  t.home.takePhoto,
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
                      ),
                      const SizedBox(height: 16),

                      // Secondary actions row
                      Row(
                        children: [
                          // Gallery button
                          Expanded(
                            child: Semantics(
                              label: t.home.loadFromGallery,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: Icon(
                                  Icons.photo_library_outlined,
                                  size: 20,
                                  color: context.colors.textPrimary,
                                ),
                                label: Text(
                                  t.home.gallery,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: context.colors.border,
                                    width: 1.5,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Paste link button
                          Expanded(
                            child: Semantics(
                              label: t.home.pasteLink,
                              child: OutlinedButton.icon(
                                onPressed: _pasteLink,
                                icon: Icon(
                                  Icons.link,
                                  size: 20,
                                  color: context.colors.textPrimary,
                                ),
                                label: Text(
                                  t.home.pasteLink,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: context.colors.border,
                                    width: 1.5,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Photo tips card
                      const PhotoTipsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }
}
