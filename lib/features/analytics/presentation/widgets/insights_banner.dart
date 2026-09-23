import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';

/// Peach/coral insight banner matching the reference screenshot:
/// [✦ Sparkle icon] "You spent $108 less than last month. Keep being picky 👏"
class InsightsBanner extends StatelessWidget {
  const InsightsBanner({
    this.message = 'You spent \$108 less than last month. Keep being picky 👏',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF281C1A) : AppColors.coralSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? const Color(0xFF3D2622)
              : AppColors.coralMuted,
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Circular coral icon with sparkles
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Message Text
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : const Color(0xFF2A1C18),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
