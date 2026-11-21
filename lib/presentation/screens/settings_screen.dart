// ============================================================================
// ملف: settings_screen.dart
// الوظيفة: تجميع كل إعدادات التطبيق العامة:
// - تبديل الوضع الداكن/الفاتح.
// - تصدير/استيراد نسخة احتياطية كاملة (متاح للمدير فقط).
// - إضافة حسابات موظفين جدد (متاح للمدير فقط).
// - تسجيل الخروج.
// ============================================================================

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/core/utils/validators.dart';
import 'package:almugahed_cars/presentation/providers/auth_providers.dart';
import 'package:almugahed_cars/presentation/providers/backup_providers.dart';
import 'package:almugahed_cars/presentation/providers/contract_providers.dart';
import 'package:almugahed_cars/presentation/providers/settings_providers.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';
import 'package:almugahed_cars/presentation/screens/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBusy = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportBackup() async {
    setState(() => _isBusy = true);
    try {
      await ref.read(backupServiceProvider).exportBackup();
      if (mounted) _showSnack('تم إنشاء النسخة الاحتياطية وفتح نافذة المشاركة');
    } catch (e) {
      if (mounted) _showSnack('حدث خطأ أثناء التصدير: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استيراد نسخة احتياطية'),
        content: const Text(
          'سيتم استبدال جميع البيانات الحالية (العقود والسيارات والمستخدمين) '
          'بمحتوى الملف المُستورد. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('متابعة', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _isBusy = true);
    try {
      final file = File(result.files.single.path!);
      await ref.read(backupServiceProvider).importBackup(file);
      ref.invalidate(contractsControllerProvider);
      ref.invalidate(vehiclesControllerProvider);
      if (mounted) _showSnack('تم استيراد النسخة الاحتياطية بنجاح');
    } catch (e) {
      if (mounted) _showSnack('فشل الاستيراد: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _showAddEmployeeDialog() async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    UserRole role = UserRole.employee;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة مستخدم جديد'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  validator: (v) => Validators.required(v, fieldName: 'اسم المستخدم'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordCtrl,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'كلمة المرور 4 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserRole>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('موظف', style: TextStyle(fontSize: 13)),
                        value: UserRole.employee,
                        groupValue: role,
                        onChanged: (v) => setDialogState(() => role = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserRole>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('مدير', style: TextStyle(fontSize: 13)),
                        value: UserRole.admin,
                        groupValue: role,
                        onChanged: (v) => setDialogState(() => role = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final repo = ref.read(authRepositoryProvider);
                final added = await repo.addUser(usernameCtrl.text.trim(), passwordCtrl.text, role);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(allUsersProvider);
                if (!added && mounted) _showSnack('اسم المستخدم موجود مسبقًا');
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider);
    final isManager = ref.watch(authControllerProvider.notifier).isManager;
    final themeMode = ref.watch(themeModeControllerProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: _isBusy
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlack,
                        child: Text(
                          (currentUser?.username.isNotEmpty == true
                                  ? currentUser!.username[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(color: AppColors.secondaryWhite),
                        ),
                      ),
                      title: Text(currentUser?.username ?? ''),
                      subtitle: Text(currentUser?.role.label ?? ''),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('الوضع الداكن'),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (v) => ref.read(themeModeControllerProvider.notifier).toggle(v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isManager) ...[
                    const Text('النسخ الاحتياطي', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.upload_outlined),
                            title: const Text('تصدير نسخة احتياطية'),
                            subtitle: const Text('حفظ/مشاركة كل بيانات التطبيق كملف JSON'),
                            onTap: _exportBackup,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.download_outlined, color: AppColors.error),
                            title: const Text('استيراد نسخة احتياطية'),
                            subtitle: const Text('يستبدل كل البيانات الحالية'),
                            onTap: _importBackup,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المستخدمون', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _showAddEmployeeDialog,
                          icon: const Icon(Icons.person_add_alt_outlined, size: 18),
                          label: const Text('إضافة'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    usersAsync.when(
                      data: (users) => Card(
                        child: Column(
                          children: users
                              .map((u) => ListTile(
                                    leading: const Icon(Icons.person_outline),
                                    title: Text(u.username),
                                    trailing: Text(u.role.label,
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ))
                              .toList(),
                        ),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.logout, color: AppColors.error),
                      title: const Text('تسجيل الخروج'),
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '${AppConstants.appName} — الإصدار 1.0.0',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
