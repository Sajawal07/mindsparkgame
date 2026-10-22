import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/game_providers.dart';
import '../../data/services/app_backend_service.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../shared/widgets/mindspark_loading_indicator.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AudioSettings _settings;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _settings = AudioService.instance.settings;
    _notificationsEnabled = StorageService.instance.getNotificationsEnabled();
  }

  Future<void> _persist() async {
    await ref.read(gameStateProvider).updateAudioSettings(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Mute all audio'),
            value: _settings.muted,
            onChanged: (v) async {
              await AudioService.instance.playButtonTap();
              setState(() => _settings = _settings.copyWith(muted: v));
              await _persist();
            },
          ),
            SwitchListTile(
              title: const Text('Enable game notifications'),
              value: _notificationsEnabled,
              onChanged: (v) async {
                await AudioService.instance.playButtonTap();
                setState(() => _notificationsEnabled = v);
                await StorageService.instance.setNotificationsEnabled(v);
                await NotificationService.instance.setEnabled(v);
              },
            ),
          const Divider(),
          _VolumeSlider(
            label: 'Master volume',
            value: _settings.masterVolume,
            onChanged: (v) {
              setState(() => _settings = _settings.copyWith(masterVolume: v));
              _persist();
            },
          ),
          _VolumeSlider(
            label: 'Music volume',
            value: _settings.musicVolume,
            onChanged: (v) {
              setState(() => _settings = _settings.copyWith(musicVolume: v));
              _persist();
            },
          ),
          _VolumeSlider(
            label: 'Sound effects',
            value: _settings.sfxVolume,
            onChanged: (v) {
              setState(() => _settings = _settings.copyWith(sfxVolume: v));
              _persist();
            },
            onChangeEnd: (_) => AudioService.instance.playSfx(Sfx.button),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          const Divider(),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.terms),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.primaryLight),
            title: const Text('Contact Us'),
            subtitle: const Text(
              'sajawal0005@gmail.com',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: 'sajawal0005@gmail.com',
                queryParameters: {
                  'subject': 'MindSpark Support',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Test sound'),
            trailing: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => AudioService.instance.playSfx(Sfx.correct),
            ),
          ),
          const Divider(),
          if (AppBackendService.instance.isAnonymous) ...[
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primaryLight),
              title: const Text('Link Google Account'),
              subtitle: const Text(
                'Back up your guest progress and coin balance to Google',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await AppBackendService.instance.linkWithGoogle();
                if (!context.mounted) return;
                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message ?? 'Google account linked!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  setState(() {});
                  ref.read(gameStateProvider).refresh();
                } else if (result.status == LinkGoogleStatus.credentialAlreadyInUse) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1B2E),
                      title: const Text('Account Already In Use', style: TextStyle(color: Colors.white)),
                      content: Text(
                        result.message ?? 'This Google account is already linked to another player.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (result.status != LinkGoogleStatus.cancelled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message ?? 'Failed to link Google account'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
            const Divider(),
          ],
          ListTile(
            title: const Text('Sign Out'),
            trailing: const Icon(Icons.logout, color: Colors.white70),
            onTap: () async {
              final isGuest = AppBackendService.instance.isAnonymous;

              if (isGuest) {
                // Show warning specifically for anonymous guest accounts
                final action = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1B2E),
                    title: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                        SizedBox(width: 8),
                        Text('Guest Account Warning', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    content: const Text(
                      'You are playing as a Guest. If you sign out without linking your account to Google, your local game data, streak, and coin balance may be lost on this device.\n\nWould you like to link a Google account first, or sign out anyway?',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, 'cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, 'signout'),
                        child: const Text(
                          'Sign Out Anyway',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, 'link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Link Google Account'),
                      ),
                    ],
                  ),
                );

                if (action == 'link' && context.mounted) {
                  final result = await AppBackendService.instance.linkWithGoogle();
                  if (!context.mounted) return;
                  if (result.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message ?? 'Google account linked successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    setState(() {});
                    ref.read(gameStateProvider).refresh();
                  }
                  return;
                } else if (action == 'signout' && context.mounted) {
                  await AppBackendService.instance.signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                }
              } else {
                // Standard Google user sign-out
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1B2E),
                    title: const Text('Sign Out?', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await AppBackendService.instance.signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                }
              }
            },
          ),
          ListTile(
            title: const Text(
              'Delete Account & Data',
              style: TextStyle(color: Colors.redAccent),
            ),
            trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onTap: () async {
              final isGuest = AppBackendService.instance.isAnonymous;
              final userEmail = AppBackendService.instance.currentUser?.email;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1B2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Delete Account?',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    isGuest
                        ? 'Warning: You are playing as a Guest. Deleting will immediately wipe your progress and local data.\n\nAre you sure you want to proceed?'
                        : 'Warning: Deleting your account ($userEmail) will permanently erase all your game progress, coin balance, high scores, and stats.\n\n30-Day Procedure:\n1. Your deletion request will be submitted to the administrator.\n2. You will be logged out immediately.\n3. Your account and data will be permanently deleted within 30 days.\n4. You will not be able to log in with this Google account until permanent deletion is complete.\n\nDo you agree and wish to proceed?',
                    style: const TextStyle(color: Colors.white70, height: 1.45, fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Agree & Request Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: MindSparkLoadingIndicator(size: 84),
                  ),
                );

                final result = await AppBackendService.instance.requestAccountDeletion();

                if (context.mounted) {
                  Navigator.pop(context); // close loading dialog

                  if (result.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account deletion request submitted. You have been logged out.',
                        ),
                        backgroundColor: Color(0xFF3D2B5E),
                        duration: Duration(seconds: 4),
                      ),
                    );
                    context.go(AppRoutes.login);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message ?? 'Failed to submit deletion request.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
