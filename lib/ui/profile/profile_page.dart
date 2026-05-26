import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/auth/data/auth_repository.dart';
import 'package:ai_teacher/core/streak/presentation/streak_check_in_controller.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/profile/edit_password_dialog.dart';
import 'package:ai_teacher/ui/profile/edit_profile_dialog.dart';
import 'package:ai_teacher/ui/profile/subscription_details_sheet.dart';
import 'package:ai_teacher/ui/profile/widget/profile_group_card.dart';
import 'package:ai_teacher/ui/profile/widget/profile_pill_badge.dart';
import 'package:ai_teacher/ui/profile/widget/profile_row.dart';
import 'package:ai_teacher/ui/profile/widget/profile_section_label.dart';
import 'package:ai_teacher/ui/profile/widget/profile_toggle.dart';
import 'package:ai_teacher/ui/profile/widget/profile_trailing_value.dart';
import 'package:ai_teacher/ui/profile/widget/profile_user_card.dart';
import 'package:ai_teacher/utils/uz_phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _pushNotifications = true;
  bool _streakReminder = true;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text("Hisobingizdan chiqishni xohlaysizmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    ref.invalidate(currentUserProvider);
    ref.invalidate(streakCheckInProvider);
    context.goNamed(AppRoute.onboarding.name);
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://www.myteacher.uz/docs/privacy_policy.html');
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  Future<void> _copyReferral(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Referal kod nusxalandi')));
  }

  Future<void> _openEditProfile() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    await showDialog<bool>(
      context: context,
      builder: (_) => EditProfileDialog(initialFirstName: user.firstName),
    );
  }

  Future<void> _openEditPassword() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const EditPasswordDialog(),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("Parol yangilandi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final hideSubscriptionSection =
        user?.phoneNumber.endsWith('990000000') ?? false;
    final displayName = user?.fullName ?? '';
    final displayPhone = UzPhoneFormatter.formatInternational(
      user?.phoneNumber ?? '',
    );
    final displayInitial = user?.initial ?? '';
    final subscription = user?.activeSubscription;
    final hasActiveSubscription = subscription != null;
    final proPaketSubtitle = hasActiveSubscription
        ? _subscriptionSubtitle(subscription.endDate)
        : "Faol obuna yo'q";

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileUserCard(
            name: displayName,
            subtitle: displayPhone,
            initial: displayInitial,
          ),
          const ProfileSectionLabel(text: 'HISOB'),
          ProfileGroupCard(
            children: [
              ProfileRow(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBackground: const Color(0xFFEFF6FF),
                title: "Shaxsiy ma'lumotlar",
                subtitle: 'Ism',
                trailing: const ProfileTrailingValue(),
                onTap: _openEditProfile,
              ),
              ProfileRow(
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.primary,
                iconBackground: const Color(0xFFF0FDFA),
                title: 'Parol',
                subtitle: "Parolni o'zgartirish",
                trailing: const ProfileTrailingValue(),
                onTap: _openEditPassword,
              ),
              ProfileRow(
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFFFB923C),
                iconBackground: const Color(0xFFFFF7ED),
                title: 'Telefon',
                subtitle: displayPhone,
                trailing: const ProfileTrailingValue(showChevron: false),
              ),
              ProfileRow(
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBackground: const Color(0xFFEFF6FF),
                title: 'Email',
                subtitle: (user?.email?.isNotEmpty ?? false)
                    ? user!.email!
                    : 'Kiritilmagan',
                trailing: const ProfileTrailingValue(showChevron: false),
              ),
              if ((user?.referralCode ?? '').isNotEmpty)
                ProfileRow(
                  icon: Icons.qr_code_2_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBackground: const Color(0xFFF5F3FF),
                  title: 'Referal kod',
                  subtitle: user!.referralCode!,
                  trailing: const ProfileTrailingValue(
                    value: 'Nusxa',
                    showChevron: false,
                  ),
                  onTap: () => _copyReferral(user.referralCode!),
                ),
            ],
          ),
          if (!hideSubscriptionSection) ...[
            const ProfileSectionLabel(text: 'OBUNA'),
            ProfileGroupCard(
              children: [
                ProfileRow(
                  icon: Icons.star_outline_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBackground: const Color(0xFFFEF9C3),
                  title: 'Pro paket',
                  subtitle: proPaketSubtitle,
                  trailing: ProfileTrailingValue(
                    badge: hasActiveSubscription
                        ? const ProfilePillBadge(
                            label: 'Faol',
                            background: Color(0xFFDCFCE7),
                            textColor: Color(0xFF15803D),
                          )
                        : null,
                  ),
                  onTap: () => SubscriptionDetailsSheet.show(context),
                ),
                ProfileRow(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF64748B),
                  iconBackground: const Color(0xFFF1F5F9),
                  title: "To'lov tarixi",
                  trailing: const ProfileTrailingValue(
                    badge: ProfilePillBadge(
                      label: '0',
                      background: Color(0xFFFEF9C3),
                      textColor: Color(0xFFB45309),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ],
          const ProfileSectionLabel(text: 'BILDIRISHNOMALAR'),
          ProfileGroupCard(
            children: [
              ProfileRow(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFD97706),
                iconBackground: const Color(0xFFFEF9C3),
                title: 'Push xabarnomalar',
                trailing: ProfileToggle(
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
              ),
              ProfileRow(
                icon: Icons.star_outline_rounded,
                iconColor: const Color(0xFF22C55E),
                iconBackground: const Color(0xFFF0FDF4),
                title: 'Streak eslatmasi',
                subtitle: 'Har kuni soat 20:00',
                trailing: ProfileToggle(
                  value: _streakReminder,
                  onChanged: (v) => setState(() => _streakReminder = v),
                ),
              ),
            ],
          ),
          const ProfileSectionLabel(text: 'ILOVA'),
          ProfileGroupCard(
            children: [
              ProfileRow(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF64748B),
                iconBackground: const Color(0xFFF1F5F9),
                title: 'Maxfiylik siyosati',
                trailing: const ProfileTrailingValue(),
                onTap: _openPrivacyPolicy,
              ),
              ProfileRow(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF64748B),
                iconBackground: const Color(0xFFF1F5F9),
                title: 'Versiya',
                trailing: ProfileTrailingValue(
                  value: _appVersion == null ? '' : 'v$_appVersion',
                  showChevron: false,
                ),
              ),
            ],
          ),
          const ProfileSectionLabel(text: 'BOSHQA'),
          ProfileGroupCard(
            children: [
              ProfileRow(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBackground: const Color(0xFFFFF1F2),
                title: 'Chiqish',
                titleColor: const Color(0xFFEF4444),
                trailing: const ProfileTrailingValue(
                  chevronColor: Color(0xFFEF4444),
                ),
                onTap: _logout,
              ),
              ProfileRow(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBackground: const Color(0xFFFFF1F2),
                title: "Hisobni o'chirish",
                subtitle: "Bu amalni qaytarib bo'lmaydi",
                titleColor: const Color(0xFFEF4444),
                trailing: const ProfileTrailingValue(
                  chevronColor: Color(0xFFEF4444),
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _uzMonthsGenitive = [
  'yanvargacha',
  'fevralgacha',
  'martgacha',
  'aprelgacha',
  'maygacha',
  'iyungacha',
  'iyulgacha',
  'avgustgacha',
  'sentabrgacha',
  'oktabrgacha',
  'noyabrgacha',
  'dekabrgacha',
];

String _subscriptionSubtitle(DateTime endDate) {
  final now = DateTime.now();
  final endLocal = endDate.toLocal();
  final daysLeft = endLocal
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  final monthName = (endLocal.month >= 1 && endLocal.month <= 12)
      ? _uzMonthsGenitive[endLocal.month - 1]
      : '';
  final left = daysLeft > 0 ? '$daysLeft kun' : 'tugadi';
  return '${endLocal.day}-$monthName faol · $left';
}
