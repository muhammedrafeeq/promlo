import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';

class TopHeader extends StatelessWidget implements PreferredSizeWidget {
  const TopHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = Provider.of<MarketplaceProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: preferredSize.height + statusBarHeight,
      padding: EdgeInsets.only(
        top: statusBarHeight,
        left: isDesktop ? 32 : 16,
        right: isDesktop ? 32 : 16,
      ),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Logo + Title
          Row(
            children: [
              Image.asset(
                'assets/promlo_logo_v6.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => provider.setActiveTab(0),
                borderRadius: BorderRadius.circular(6),
                child: Text(
                  'Promlo',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ],
          ),

          // Center (Desktop Search Bar)
          if (isDesktop)
            Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: colors.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (query) => provider.setSearchQuery(query),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search prompts...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),

          // Right: Mobile Search Icon + Profile Avatar
          Row(
            children: [
              IconButton(
                icon: Icon(
                  provider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: colors.primary,
                  size: 20,
                ),
                onPressed: provider.toggleTheme,
                tooltip: provider.isDarkMode ? 'Light mode' : 'Dark mode',
              ),
              const SizedBox(width: 2),

              // Glowing User Profile Avatar
              Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmuUirJHpRCeIepCurZyWxJshLsHRVOLjmG9hQeQpZgWxm0f-LuLdiDSCITmti5CBP6SRzMdgSyXp4AheHxJYlRtTEtupWEGkBcMieQdaEu_Pia2gMBuA10S9o3z9Dcp5TmVFv0fJfP49U0FPIfoox0c5CwIE9meh3kLL0HUTr57Hruo9xmK5e2FsDovZK1EV-pnEckUoeDkRcfJEjqjzgE3xSfuASd-r9YCZr7BJ-ODNRSiCLt5LJ1bhcO_mIjOPZD1lu3gj_PQ8',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colors.primaryContainer,
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
