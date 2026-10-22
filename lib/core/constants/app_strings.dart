abstract final class AppStrings {
  static const String appName = 'MindSpark';
  static const String tagline = 'Daily Brain Challenge';

  static const String iqDisclaimer =
      'IQ scores and famous mind comparisons are for entertainment only. '
      'This is NOT a clinically validated IQ assessment.';

  static const String onboardingTitle1 = 'Train Your Brain Daily';
  static const String onboardingBody1 =
      'Complete 8 unique mini-puzzles every day — math, memory, patterns, words, and more.';

  static const String onboardingTitle2 = 'Earn Your Brain Score';
  static const String onboardingBody2 =
      'Get a score out of 1000 and discover your IQ rank — from Just Warming Up to Beyond Einstein.';

  static const String onboardingTitle3 = 'Grow & Share';
  static const String onboardingBody3 =
      'Earn coins, level up, unlock themes, and share your results with friends.';

  static const String privacyPolicyTitle = 'MindSpark Privacy Policy';
  static const String privacyPolicyUpdated = 'Last updated: June 2026';

  static const List<PrivacyPolicySectionData> privacyPolicySections = [
    PrivacyPolicySectionData(
      title: 'Overview',
      body:
          'MindSpark is an offline-first brain training game. We designed the app '
          'to work without creating an online account. Your game progress is stored '
          'locally on your device.',
    ),
    PrivacyPolicySectionData(
      title: 'Data We Store',
      body:
          'The app saves gameplay progress on your device using local storage '
          '(Hive). This includes scores, coins, XP, streaks, unlocked items, '
          'Arena Points, and audio settings. We do not collect your name, email, '
          'or phone number unless you choose to share them elsewhere.',
    ),
    PrivacyPolicySectionData(
      title: 'Data Sharing',
      body:
          'MindSpark does not sell your personal data. If you use the Share Result '
          'feature, you choose what to share through your device\'s share sheet. '
          'We do not receive the contents of those shares.',
    ),
    PrivacyPolicySectionData(
      title: 'Internet Access',
      body:
          'The app works offline. Internet may be used in the future for optional '
          'features such as leaderboards, analytics, or in-app purchases. Those '
          'features will be disclosed in app updates and this policy will be updated.',
    ),
    PrivacyPolicySectionData(
      title: 'Children',
      body:
          'MindSpark is suitable for general audiences. We do not knowingly collect '
          'personal information from children. If you believe a child has provided '
          'personal data through the app, contact us and we will assist with removal.',
    ),
    PrivacyPolicySectionData(
      title: 'Your Choices',
      body:
          'You can reset progress by clearing app data from your device settings. '
          'Uninstalling the app removes locally stored data unless your device backs '
          'it up through system backup services.',
    ),
    PrivacyPolicySectionData(
      title: 'Contact',
      body:
          'For privacy questions about MindSpark, contact the developer through '
          'the support email listed on the Google Play Store listing.',
    ),
  ];
}

class PrivacyPolicySectionData {
  const PrivacyPolicySectionData({required this.title, required this.body});

  final String title;
  final String body;
}
