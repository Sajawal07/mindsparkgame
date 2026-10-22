import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionTitle('1. Acceptance of Terms'),
          _Body(
            'By downloading, installing, or using MindSpark ("App"), you agree to be bound by these Terms of Service. If you do not agree, please do not use the App. You must be at least 13 years old to use this App.',
          ),
          _SectionTitle('2. Account & Authentication'),
          _Body(
            'You must sign in with a valid Google account to access MindSpark. You are responsible for maintaining the confidentiality of your account. We reserve the right to suspend or terminate accounts that violate these terms.',
          ),
          _SectionTitle('3. Use of the App'),
          _Body(
            'MindSpark is provided for personal, non-commercial entertainment and educational purposes. You agree NOT to:\n\n• Cheat, hack, or manipulate game scores\n• Reverse-engineer or decompile any part of the App\n• Use the App for any unlawful purpose\n• Attempt to gain unauthorised access to our systems',
          ),
          _SectionTitle('4. Virtual Currency & Items'),
          _Body(
            'Coins and in-game items earned within MindSpark have no real-world monetary value. They cannot be exchanged, transferred, or redeemed for real money. We reserve the right to modify, reset, or remove virtual items at any time.',
          ),
          _SectionTitle('5. Intellectual Property'),
          _Body(
            'All content in MindSpark — including graphics, text, logos, game mechanics, and audio — is the exclusive property of MindSpark and is protected by intellectual property laws. You may not copy, reproduce, or distribute any content without prior written permission.',
          ),
          _SectionTitle('6. Privacy'),
          _Body(
            'Your use of the App is also governed by our Privacy Policy. By using MindSpark, you consent to the collection and use of your information as described in the Privacy Policy.',
          ),
          _SectionTitle('7. Disclaimers'),
          _Body(
            'MindSpark is provided "as is" without warranties of any kind. We do not guarantee that the App will be error-free, uninterrupted, or free of viruses. Use of the App is at your own risk.',
          ),
          _SectionTitle('8. Limitation of Liability'),
          _Body(
            'To the maximum extent permitted by law, MindSpark shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App.',
          ),
          _SectionTitle('9. Changes to Terms'),
          _Body(
            'We may update these Terms at any time. Continued use of the App after changes are posted constitutes acceptance of the revised Terms.',
          ),
          _SectionTitle('10. Contact Us'),
          _Body(
            'If you have questions about these Terms, contact us at:\n📧 sajawal0005@gmail.com',
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
    );
  }
}
