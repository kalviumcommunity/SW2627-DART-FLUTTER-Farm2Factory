import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class CallHelper {
  /// Clean phone number by removing spaces, brackets, hyphens (keeping digits and optional '+')
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  /// Launch Default Phone Dialer (`tel:<phone>`)
  static Future<void> launchPhoneDialer(BuildContext context, String phone) async {
    final clean = cleanPhoneNumber(phone);
    final Uri phoneUri = Uri(scheme: 'tel', path: clean);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Unable to open phone dialer for $phone');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error launching phone dialer: $e');
      }
    }
  }

  /// Launch Truecaller (`truecaller://call?number=<phone>`)
  static Future<void> launchTruecaller(BuildContext context, String phone) async {
    final clean = cleanPhoneNumber(phone);
    final Uri truecallerUri = Uri.parse('truecaller://call?number=$clean');

    try {
      final canLaunch = await canLaunchUrl(truecallerUri);
      if (canLaunch) {
        await launchUrl(truecallerUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showTruecallerNotInstalledDialog(context, phone);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showTruecallerNotInstalledDialog(context, phone);
      }
    }
  }

  /// Launch WhatsApp (`whatsapp://send?phone=<phone>` or `https://wa.me/<phone>`)
  static Future<void> launchWhatsApp(BuildContext context, String phone) async {
    var clean = cleanPhoneNumber(phone);
    if (!clean.startsWith('+') && clean.length == 10) {
      clean = '+91$clean'; // Default country code for Indian numbers if 10-digit
    }
    final digits = clean.replaceAll('+', '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$digits');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'WhatsApp is not installed or could not be opened.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error opening WhatsApp: $e');
      }
    }
  }

  /// Shows the interactive Call Chooser Modal Bottom Sheet
  static void showCallChooser(
    BuildContext context, {
    required String name,
    required String phone,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle Bar
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with Farmer Info and Copy button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardMint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call,
                          color: AppTheme.brandGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Call $name',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Copy Phone Number Action
                      IconButton(
                        tooltip: 'Copy Number',
                        icon: const Icon(Icons.copy_outlined, size: 19, color: Colors.grey),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: phone));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied $phone to clipboard'),
                              backgroundColor: AppTheme.brandGreen,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose how you would like to connect:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option 1: Native Phone Dialer
                  _CallAppOptionTile(
                    title: 'Phone',
                    subtitle: 'Standard cellular call via device dialer',
                    icon: Icons.phone_in_talk_rounded,
                    iconBgColor: AppTheme.cardMint,
                    iconColor: AppTheme.brandGreen,
                    badgeLabel: 'Default',
                    badgeColor: AppTheme.brandGreen,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      launchPhoneDialer(context, phone);
                    },
                  ),

                  const SizedBox(height: 10),

                  // Option 2: Truecaller
                  _CallAppOptionTile(
                    title: 'Truecaller',
                    subtitle: 'Caller ID & spam verification',
                    icon: Icons.shield_outlined,
                    iconBgColor: const Color(0xFFE8F1FD),
                    iconColor: const Color(0xFF007AFF),
                    badgeLabel: 'Caller ID',
                    badgeColor: const Color(0xFF007AFF),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      launchTruecaller(context, phone);
                    },
                  ),

                  const SizedBox(height: 10),

                  // Option 3: WhatsApp
                  _CallAppOptionTile(
                    title: 'WhatsApp',
                    subtitle: 'Internet voice call or message',
                    icon: Icons.chat_bubble_outline_rounded,
                    iconBgColor: const Color(0xFFE8F8F0),
                    iconColor: const Color(0xFF25D366),
                    badgeLabel: 'Chat / Call',
                    badgeColor: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      launchWhatsApp(context, phone);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showTruecallerNotInstalledDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF007AFF)),
            SizedBox(width: 8),
            Text(
              'Truecaller Not Found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Truecaller is not installed on this device or its deep link is unavailable.\n\nWould you like to place the call using the standard Phone app instead?',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              launchPhoneDialer(context, phone);
            },
            child: const Text('Call via Phone', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CallAppOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? badgeLabel;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _CallAppOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.badgeLabel,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconBgColor,
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (badgeLabel != null && badgeColor != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor!.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeLabel!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
