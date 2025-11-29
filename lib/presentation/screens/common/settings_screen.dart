import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Settings Screen - شاشة الإعدادات
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('لم يتم تسجيل الدخول'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User Profile Card
                  _buildUserProfileCard(context, user),

                  const SizedBox(height: AppSpacing.sm),

                  // Account Settings
                  _buildSection(
                    title: 'الحساب',
                    items: [
                      _SettingItem(
                        icon: Icons.person,
                        title: 'الملف الشخصي',
                        subtitle: 'عرض وتعديل معلوماتك الشخصية',
                        onTap: () => context.push(AppRoutes.profile),
                      ),
                      _SettingItem(
                        icon: Icons.email,
                        title: 'البريد الإلكتروني',
                        subtitle: user.email,
                        trailing: const SizedBox.shrink(),
                      ),
                      if (user.phone != null)
                        _SettingItem(
                          icon: Icons.phone,
                          title: 'رقم الهاتف',
                          subtitle: user.phone!,
                          trailing: const SizedBox.shrink(),
                        ),
                      _SettingItem(
                        icon: Icons.badge,
                        title: 'الدور',
                        subtitle: user.role.arabicLabel,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            user.shuttleRole ?? user.role.arabicLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Company & Organization
                  if (user.companyId != null || user.allowedCompanyIds.isNotEmpty)
                    _buildSection(
                      title: 'الشركة والمؤسسة',
                      items: [
                        if (user.companyId != null)
                          _SettingItem(
                            icon: Icons.business,
                            title: 'الشركة الحالية',
                            subtitle: 'Company ID: ${user.companyId}',
                            trailing: const SizedBox.shrink(),
                          ),
                        if (user.allowedCompanyIds.isNotEmpty)
                          _SettingItem(
                            icon: Icons.corporate_fare,
                            title: 'الشركات المتاحة',
                            subtitle: '${user.allowedCompanyIds.length} شركة',
                            onTap: () => _showCompaniesDialog(context, user),
                          ),
                        if (user.partnerId != null)
                          _SettingItem(
                            icon: Icons.handshake,
                            title: 'Partner ID',
                            subtitle: user.partnerId.toString(),
                            trailing: const SizedBox.shrink(),
                          ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.sm),

                  // Permissions & Groups
                  if (user.groups.isNotEmpty || user.permissions.isNotEmpty)
                    _buildSection(
                      title: 'الصلاحيات والمجموعات',
                      items: [
                        if (user.groups.isNotEmpty)
                          _SettingItem(
                            icon: Icons.group,
                            title: 'المجموعات',
                            subtitle: '${user.groups.length} مجموعة',
                            onTap: () => _showGroupsDialog(context, user),
                          ),
                        if (user.permissions.isNotEmpty)
                          _SettingItem(
                            icon: Icons.security,
                            title: 'الصلاحيات',
                            subtitle: 'عرض صلاحياتك في النظام',
                            onTap: () => _showPermissionsDialog(context, user),
                          ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.sm),

                  // App Settings
                  _buildSection(
                    title: 'إعدادات التطبيق',
                    items: [
                      _SettingItem(
                        icon: Icons.notifications,
                        title: 'الإشعارات',
                        subtitle: 'إدارة إشعارات التطبيق',
                        onTap: () {
                          // TODO: Navigate to notifications settings
                        },
                      ),
                      _SettingItem(
                        icon: Icons.language,
                        title: 'اللغة',
                        subtitle: 'العربية',
                        onTap: () {
                          // TODO: Navigate to language settings
                        },
                      ),
                      _SettingItem(
                        icon: Icons.dark_mode,
                        title: 'المظهر',
                        subtitle: 'فاتح',
                        onTap: () {
                          // TODO: Navigate to theme settings
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // About & Support
                  _buildSection(
                    title: 'حول التطبيق',
                    items: [
                      _SettingItem(
                        icon: Icons.info,
                        title: 'عن التطبيق',
                        subtitle: 'ShuttleBee v1.0.0',
                        onTap: () {
                          // TODO: Show about dialog
                        },
                      ),
                      _SettingItem(
                        icon: Icons.help,
                        title: 'المساعدة والدعم',
                        subtitle: 'احصل على المساعدة',
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      _SettingItem(
                        icon: Icons.privacy_tip,
                        title: 'سياسة الخصوصية',
                        subtitle: 'اقرأ سياسة الخصوصية',
                        onTap: () {
                          // TODO: Navigate to privacy policy
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Logout
                  _buildSection(
                    title: 'الحساب',
                    items: [
                      _SettingItem(
                        icon: Icons.logout,
                        title: 'تسجيل الخروج',
                        subtitle: 'الخروج من حسابك',
                        iconColor: AppColors.error,
                        onTap: () => _showLogoutDialog(context, ref),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, UserEntity user) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
            child: user.avatar == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    user.shuttleRole?.toUpperCase() ?? user.role.arabicLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Edit Icon
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showCompaniesDialog(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الشركات المتاحة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: user.allowedCompanyIds.map((id) {
              final isCurrent = id == user.companyId;
              return ListTile(
                leading: Icon(
                  isCurrent ? Icons.check_circle : Icons.business,
                  color: isCurrent ? AppColors.success : AppColors.textSecondary,
                ),
                title: Text('Company $id'),
                trailing: isCurrent
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'الحالية',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      )
                    : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showGroupsDialog(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المجموعات'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.groups.map((group) {
              return Chip(
                label: Text(
                  group.replaceAll('shuttlebee.', '').replaceAll('group_shuttle_', ''),
                  style: AppTextStyles.caption,
                ),
                backgroundColor: AppColors.info.withOpacity(0.1),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الصلاحيات'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionItem('إنشاء رحلات', user.canCreate('shuttle.trip')),
              _buildPermissionItem('تعديل رحلات', user.canUpdate('shuttle.trip')),
              _buildPermissionItem('حذف رحلات', user.canDelete('shuttle.trip')),
              _buildPermissionItem('عرض المركبات', user.canRead('fleet.vehicle')),
              _buildPermissionItem('تعديل المركبات', user.canUpdate('fleet.vehicle')),
              _buildPermissionItem('إدارة الشركاء', user.canUpdate('res.partner')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String label, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: hasPermission ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: hasPermission ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

