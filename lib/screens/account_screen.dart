import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Settings Section
          _buildSectionTitle('Settings'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: 'USD',
            onTap: () {
              // TODO: Open currency selector
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.access_time,
            title: 'Timezone',
            subtitle: 'Auto',
            onTap: () {
              // TODO: Open timezone selector
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage preferences',
            onTap: () {
              // TODO: Open notifications settings
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Data'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your poker data',
            onTap: () {
              // TODO: Export data
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Manage backups',
            onTap: () {
              // TODO: Backup settings
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'View terms and conditions',
            onTap: () {
              // TODO: Open terms
            },
          ),
          
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Sign out
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}