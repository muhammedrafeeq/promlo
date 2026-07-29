import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = Provider.of<MarketplaceProvider>(context);

    return SafeArea(
      child: Container(
        height: kBottomNavigationBarHeight + 16,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(
              color: colors.outline.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context,
                index: 0,
                icon: Icons.trending_up_rounded,
                label: 'Trending',
                provider: provider),
            _buildNavItem(context,
                index: 1,
                icon: Icons.grid_view_rounded,
                label: 'Categories',
                provider: provider),
            _buildNavItem(context,
                index: 2,
                icon: Icons.folder_rounded,
                label: 'Collections',
                provider: provider,
                badgeCount: provider.savedIds.length),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required MarketplaceProvider provider,
    int badgeCount = 0,
  }) {
    final colors = AppColors.of(context);
    final isActive = provider.activeTabIndex == index;

    return InkWell(
      onTap: () => provider.setActiveTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                if (badgeCount > 0 && !isActive)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? colors.primary
                    : colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
