import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';

/// Profile Screen - شاشة الملف الشخصي
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: const Center(child: Text('لم يتم تسجيل الدخول')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar & Basic Info
            _buildUserHeader(user),
            
            const SizedBox(height: AppSpacing.lg),
            
            // User Information Card
            _buildUserInfo(user),
            
            const SizedBox(height: AppSpacing.md),
            
            // Permissions Card
            if (user.permissions.isNotEmpty) ...[
              _buildPermissions(user),
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Companies Card
            if (user.allowedCompanyIds.isNotEmpty) ...[
              _buildCompanies(user),
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Groups Card
            if (user.groups.isNotEmpty) ...[
              _buildGroups(user),
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Custom Fields Card
            if (user.customFields.isNotEmpty) ...[
              _buildCustomFields(user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: AppTextStyles.heading1.copyWith(color: Colors.white),
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
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      user.role.arabicLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات المستخدم', style: AppTextStyles.heading4),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(Icons.person, 'الاسم', user.name),
            _buildInfoRow(Icons.email, 'البريد الإلكتروني', user.email),
            if (user.phone != null) _buildInfoRow(Icons.phone, 'الهاتف', user.phone!),
            _buildInfoRow(Icons.badge, 'الدور', user.role.arabicLabel),
            if (user.partnerId != null)
              _buildInfoRow(Icons.business, 'Partner ID', user.partnerId.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissions(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('الصلاحيات', style: AppTextStyles.heading4),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPermissionChip('إنشاء رحلات', user.canCreate('shuttle.trip')),
            _buildPermissionChip('تعديل المركبات', user.canUpdate('fleet.vehicle')),
            _buildPermissionChip('حذف الشركاء', user.canDelete('res.partner')),
            _buildPermissionChip('قراءة التقارير', user.canRead('shuttle.report')),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanies(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('الشركات', style: AppTextStyles.heading4),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (user.companyId != null)
              _buildInfoRow(Icons.check_circle, 'الشركة الحالية', user.companyId.toString()),
            _buildInfoRow(
              Icons.corporate_fare,
              'عدد الشركات المتاحة',
              user.allowedCompanyIds.length.toString(),
            ),
            if (user.hasMultipleCompanies)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: user.allowedCompanyIds.map((id) {
                    return Chip(
                      label: Text('Company $id'),
                      backgroundColor: id == user.companyId
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.grey[200],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroups(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('المجموعات', style: AppTextStyles.heading4),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.groups.map((group) {
                return Chip(
                  label: Text(group),
                  backgroundColor: AppColors.info.withOpacity(0.1),
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.info,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFields(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('حقول مخصصة', style: AppTextStyles.heading4),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...user.customFields.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${entry.key}:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String label, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: hasPermission ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasPermission ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

