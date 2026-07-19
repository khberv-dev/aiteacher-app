import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/app/theme/app_radius.dart';
import 'package:ai_teacher/core/update/update_checker.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/shared/widget/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key, required this.info});

  final UpdateInfo info;

  static Future<void> show(BuildContext context, UpdateInfo info) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(info: info),
    );
  }

  Future<void> _openStore() async {
    final urlStr = info.storeUrl;
    if (urlStr == null) return;
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forced = info.type == UpdateType.forced;
    return PopScope(
      canPop: !forced,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                forced
                    ? l10n.sharedUpdateDialogForcedTitle
                    : l10n.sharedUpdateDialogOptionalTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.sharedUpdateDialogUpdateButton,
                onPressed: _openStore,
              ),
              if (!forced) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      l10n.sharedUpdateDialogLater,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
