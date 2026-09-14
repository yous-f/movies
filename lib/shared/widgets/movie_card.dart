import 'package:flutter/material.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_text_styles.dart';

class MovieCard extends StatelessWidget {
  final String imageUrl;
  final double rating;

  const MovieCard({required this.imageUrl, required this.rating});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(imageUrl),

          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/card.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
      );
    }
  }
}