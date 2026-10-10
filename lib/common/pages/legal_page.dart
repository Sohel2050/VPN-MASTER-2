import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vpn_master/core/constants/legal_texts.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/widgets/app_bar/secondary_app_bar.dart';

/// The kind of legal document shown by [LegalPage].
enum LegalType { privacy, terms }

/// Shows the Privacy Policy or the Terms & Conditions inside the app (works offline).
class LegalPage extends StatelessWidget {
  /// The route path for this page.
  static String get path => "/legal";
  /// The route name for this page.
  static String get name => "legal";

  /// Which document to show.
  final LegalType type;

  /// Creates a [LegalPage].
  const LegalPage({super.key, required this.type});

  /// Converts the `type` query parameter of the route to a [LegalType].
  static LegalType typeFromQuery(String? value) =>
      value == "terms" ? LegalType.terms : LegalType.privacy;

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalType.privacy;
    final sections = isPrivacy ? LegalTexts.privacy : LegalTexts.terms;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SecondaryAppBar(
        title: isPrivacy ? "Privacy Policy" : "Terms & Conditions",
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          children: [
            Text(
              "Last updated: ${LegalTexts.lastUpdated}",
              style: context.caption,
            ),
            SizedBox(height: 12.h),
            for (final section in sections) ...[
              Text(
                section.title,
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              SizedBox(height: 6.h),
              for (final paragraph in section.paragraphs)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(paragraph, style: context.bodyMedium),
                ),
              SizedBox(height: 10.h),
            ],
          ],
        ),
      ),
    );
  }
}
