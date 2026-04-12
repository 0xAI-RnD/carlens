import 'package:flutter/material.dart';
import 'package:carlens/services/notification_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final enabled = await NotificationService().isEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await NotificationService().setEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Impostazioni',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: context.colors.textPrimary,
                strokeWidth: 1.5,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Notifications section
                Text(
                  'NOTIFICHE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Curiosit\u00e0 del giorno',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ricevi ogni giorno una curiosit\u00e0 sulle auto storiche',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch.adaptive(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeColor: context.colors.accentRed,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Info section
                Text(
                  'INFORMAZIONI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Versione',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Text(
                          '0.13.1',
                          style: TextStyle(
                            fontSize: 15,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CARLENS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 6,
                          color: context.colors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Identifica la tua classica',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary.withValues(alpha: 0.4),
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
