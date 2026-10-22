import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppStrings.privacyPolicyTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.privacyPolicyUpdated,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          ...AppStrings.privacyPolicySections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
