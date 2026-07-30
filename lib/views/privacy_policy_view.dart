import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: colors.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 120 : 24,
          vertical: 32,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colors),
                const SizedBox(height: 40),
                _buildSection(
                  colors,
                  icon: Icons.info_outline_rounded,
                  title: '1. Information We Collect',
                  body:
                      'We collect information you provide directly when using Promlo, including prompt interactions, saved collections, and preferences. We also automatically collect usage data such as pages visited, features used, and performance metrics to improve the service.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.storage_rounded,
                  title: '2. How We Use Your Information',
                  body:
                      'We use collected information to provide, maintain, and improve Promlo, personalise your experience, analyse usage patterns, and ensure the security of the platform. We do not sell your personal information to third parties.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.share_rounded,
                  title: '3. Information Sharing',
                  body:
                      'We may share anonymised, aggregated data with analytics providers to help us understand platform usage. We may disclose information if required by law or to protect the rights, safety, and security of Promlo and its users.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.lock_outline_rounded,
                  title: '4. Data Security',
                  body:
                      'We implement industry-standard security measures to protect your data, including encryption in transit and at rest via Supabase. However, no method of transmission over the internet is 100% secure. We encourage you to use strong, unique credentials.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.cookie_outlined,
                  title: '5. Cookies & Local Storage',
                  body:
                      'Promlo uses local storage to remember your preferences such as dark/light mode and saved collections. We do not use third-party advertising cookies. Analytics cookies may be used to measure performance and improve the service.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.person_outline_rounded,
                  title: '6. Your Rights',
                  body:
                      'You have the right to access, correct, or delete any personal information we hold about you. You may also request a copy of your data or withdraw consent at any time. To exercise these rights, contact us using the details below.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.child_care_rounded,
                  title: '7. Children\'s Privacy',
                  body:
                      'Promlo is not directed to children under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided us with personal information, please contact us and we will promptly delete it.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.update_rounded,
                  title: '8. Changes to This Policy',
                  body:
                      'We may update this Privacy Policy from time to time. We will notify users of significant changes by updating the date at the top of this page. Continued use of Promlo after changes are posted constitutes acceptance of the revised policy.',
                ),
                _buildSection(
                  colors,
                  icon: Icons.mail_outline_rounded,
                  title: '9. Contact Us',
                  body:
                      'If you have questions or concerns about this Privacy Policy or how we handle your data, please reach out to us at:\n\nzerbitsolutions@gmail.com\n\nWe aim to respond to all enquiries within 5 business days.',
                ),
                const SizedBox(height: 40),
                _buildFooterNote(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Last updated: July 30, 2026',
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Privacy Policy',
          style: GoogleFonts.sora(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'At Promlo, your privacy matters. This policy explains what information we collect, how we use it, and the choices you have.',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    AppColors colors, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              body,
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colors.onSurfaceVariant,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colors.outline.withValues(alpha: 0.15)),
        ],
      ),
    );
  }

  Widget _buildFooterNote(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Promlo is committed to protecting your privacy and being transparent about our data practices.',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
