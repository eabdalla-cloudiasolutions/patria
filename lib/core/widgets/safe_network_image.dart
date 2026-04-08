import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final String fallbackAsset;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/images/placeholder.png',
  });

  @override
  Widget build(BuildContext context) {
    // Check if URL is valid
    final isValidUrl = imageUrl != null &&
        imageUrl!.isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    if (!isValidUrl) {
      // Return fallback asset image
      return Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF6B5E4B),
            strokeWidth: 2.w,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $imageUrl, Error: $error');
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F0EA),
      child: Icon(
        Icons.image_outlined,
        size: 40.sp,
        color: const Color(0xFFCACBD4),
      ),
    );
  }
}
