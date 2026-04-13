import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/masking.dart';

/// Card showing customer info with tap-to-call.
class CustomerInfoCard extends StatelessWidget {
  final String? name;
  final String? phone;
  final String? address;

  const CustomerInfoCard({super.key, this.name, this.phone, this.address});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات العميل',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
            Divider(color: theme.colorScheme.outlineVariant),
            if (name != null && name!.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(name!),
                dense: true,
              ),
            if (phone != null && phone!.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined),
                title: Text(
                  _maskPhone(phone!),
                  textDirection: TextDirection.ltr,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: 'اتصال بالعميل',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          Icons.phone,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'اتصال بالعميل',
                        onPressed: () => _launchPhone(phone!),
                      ),
                    ),
                    Semantics(
                      label: 'مراسلة عبر واتساب',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          Icons.message,
                          size: 22,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        tooltip: 'مراسلة عبر واتساب',
                        onPressed: () => _launchWhatsApp(phone!),
                      ),
                    ),
                  ],
                ),
                dense: true,
              ),
            if (address != null && address!.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(address!, maxLines: 2),
                dense: true,
              ),
          ],
        ),
      ),
    );
  }

  String _maskPhone(String phone) => maskPhoneNumber(phone);

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
