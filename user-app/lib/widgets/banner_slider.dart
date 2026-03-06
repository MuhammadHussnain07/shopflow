// filepath: lib/widgets/banner_slider.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopflow/core/theme/app_theme.dart';

class _BannerData {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradientColors;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradientColors,
  });
}

const _banners = [
  _BannerData(
    title: 'New Arrivals',
    subtitle: 'Fresh styles just dropped',
    imageUrl:
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=800&q=80',
    gradientColors: [Color(0xFF1A1A2E), Color(0x881A1A2E)],
  ),
  _BannerData(
    title: 'Summer Sale',
    subtitle: 'Up to 50% off on selected items',
    imageUrl:
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80',
    gradientColors: [Color(0xFF0F3460), Color(0x880F3460)],
  ),
  _BannerData(
    title: 'Premium Picks',
    subtitle: 'Curated for your style',
    imageUrl:
        'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800&q=80',
    gradientColors: [Color(0xFF16213E), Color(0x8816213E)],
  ),
];

class BannerSlider extends HookWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(viewportFraction: 0.92);
    final currentPage = useState(0);

    useEffect(() {
      final timer = Stream.periodic(const Duration(seconds: 4));
      final sub = timer.listen((_) {
        if (pageController.hasClients) {
          final next = (currentPage.value + 1) % _banners.length;
          pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
      return sub.cancel;
    }, []);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: pageController,
            itemCount: _banners.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _BannerCard(banner: banner),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentPage.value == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: currentPage.value == index
                    ? AppColors.primary
                    : AppColors.textGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: banner.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: banner.gradientColors),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: banner.gradientColors),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: banner.gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'EXCLUSIVE',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Shop Now',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
