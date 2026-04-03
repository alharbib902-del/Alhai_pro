/// Privacy Policy Screen - Arabic privacy policy & data rights
///
/// Displays: data collected, usage, protection, user rights.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

/// Privacy policy and data rights screen
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: 'سياسة الخصوصية',
          subtitle: 'الخصوصية وحقوق البيانات',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
          ),
          onNotificationsTap: () =>
              context.push(AppRoutes.notificationsCenter),
          userName:
              ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.info_outline_rounded,
                      color: AppColors.primary,
                      title: 'مقدمة',
                      children: const [
                        _PolicyText(
                          'نحن في الحي نلتزم بحماية خصوصيتك وبياناتك الشخصية. '
                          'توضح هذه السياسة كيف نجمع ونستخدم ونحمي بياناتك عند استخدام تطبيق نقطة البيع.',
                        ),
                        _PolicyText(
                          'آخر تحديث: مارس 2026',
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.storage_rounded,
                      color: AppColors.info,
                      title: 'البيانات التي نجمعها',
                      children: const [
                        _PolicyBullet('بيانات المتجر: اسم المتجر، العنوان، الرقم الضريبي، الشعار.'),
                        _PolicyBullet('بيانات المنتجات: أسماء المنتجات، الأسعار، الباركود، المخزون.'),
                        _PolicyBullet('بيانات المبيعات: الفواتير، طرق الدفع، المبالغ، التاريخ والوقت.'),
                        _PolicyBullet('بيانات العملاء: الاسم، رقم الهاتف، البريد الإلكتروني (اختياري)، سجل المشتريات.'),
                        _PolicyBullet('بيانات الموظفين: اسم المستخدم، الدور، سجل الورديات.'),
                        _PolicyBullet('بيانات الجهاز: نوع الجهاز، نظام التشغيل (لأغراض الدعم الفني فقط).'),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.analytics_rounded,
                      color: AppColors.secondary,
                      title: 'كيف نستخدم بياناتك',
                      children: const [
                        _PolicyBullet('تشغيل نظام نقطة البيع ومعالجة المبيعات والمدفوعات.'),
                        _PolicyBullet('إنشاء التقارير والإحصائيات لمساعدتك في إدارة متجرك.'),
                        _PolicyBullet('إدارة حسابات العملاء والديون والولاء.'),
                        _PolicyBullet('إدارة المخزون وتتبع المنتجات.'),
                        _PolicyBullet('النسخ الاحتياطي واستعادة البيانات.'),
                        _PolicyBullet('تحسين أداء التطبيق وإصلاح الأخطاء.'),
                        _PolicyText(
                          'لا نبيع بياناتك لأطراف ثالثة. لا نستخدم بياناتك لأغراض إعلانية.',
                          isBold: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.shield_rounded,
                      color: AppColors.success,
                      title: 'كيف نحمي بياناتك',
                      children: const [
                        _PolicyBullet('التخزين المحلي: جميع بيانات المبيعات والعملاء تُخزن محلياً على جهازك.'),
                        _PolicyBullet('التشفير: البيانات الحساسة مشفرة باستخدام تقنيات التشفير الحديثة.'),
                        _PolicyBullet('النسخ الاحتياطي: يمكنك إنشاء نسخ احتياطية مشفرة من بياناتك.'),
                        _PolicyBullet('المصادقة: الوصول محمي بكلمة مرور وصلاحيات المستخدمين.'),
                        _PolicyBullet('العمل بدون إنترنت: التطبيق يعمل 100% بدون اتصال، بياناتك لا تُرسل لخوادم خارجية.'),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.gavel_rounded,
                      color: AppColors.warning,
                      title: 'حقوقك',
                      children: const [
                        _PolicyRight(
                          title: 'حق الوصول',
                          description: 'يحق لك الاطلاع على جميع بياناتك المخزنة في التطبيق في أي وقت.',
                        ),
                        _PolicyRight(
                          title: 'حق التصحيح',
                          description: 'يحق لك تعديل أو تصحيح أي بيانات غير دقيقة.',
                        ),
                        _PolicyRight(
                          title: 'حق الحذف',
                          description: 'يحق لك طلب حذف بياناتك الشخصية. يمكنك حذف بيانات العملاء من شاشة إدارة العملاء.',
                        ),
                        _PolicyRight(
                          title: 'حق التصدير',
                          description: 'يحق لك تصدير نسخة من بياناتك بصيغة JSON.',
                        ),
                        _PolicyRight(
                          title: 'حق الإلغاء',
                          description: 'يحق لك إلغاء أي موافقة سابقة على معالجة بياناتك.',
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.error,
                      title: 'حذف البيانات',
                      children: const [
                        _PolicyText(
                          'يمكنك حذف بيانات العملاء من خلال إعدادات التطبيق. عند حذف بيانات عميل:',
                        ),
                        _PolicyBullet('يتم حذف المعلومات الشخصية (الاسم، الهاتف، البريد) بشكل نهائي.'),
                        _PolicyBullet('يتم إخفاء هوية العميل في سجلات المبيعات السابقة (تظهر كـ "عميل محذوف").'),
                        _PolicyBullet('يتم حذف حسابات الديون والعناوين المرتبطة.'),
                        _PolicyText(
                          'ملاحظة: لا يمكن التراجع عن حذف البيانات بعد تنفيذه.',
                          isBold: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.contact_mail_rounded,
                      color: AppColors.primaryDark,
                      title: 'التواصل معنا',
                      children: const [
                        _PolicyText(
                          'إذا كان لديك أي أسئلة حول سياسة الخصوصية أو ترغب في ممارسة حقوقك، '
                          'يمكنك التواصل معنا عبر:',
                        ),
                        _PolicyBullet('البريد الإلكتروني: privacy@alhai.app'),
                        _PolicyBullet('الدعم الفني داخل التطبيق'),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

/// Plain text paragraph
class _PolicyText extends StatelessWidget {
  final String text;
  final bool isBold;

  const _PolicyText(this.text, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.getTextSecondary(isDark),
          height: 1.7,
        ),
      ),
    );
  }
}

/// Bullet point item
class _PolicyBullet extends StatelessWidget {
  final String text;

  const _PolicyBullet(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: AlhaiSpacing.xs, left: AlhaiSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.getTextMuted(isDark),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rights item with title and description
class _PolicyRight extends StatelessWidget {
  final String title;
  final String description;

  const _PolicyRight({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
