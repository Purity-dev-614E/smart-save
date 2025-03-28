import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // User Info
              Text(
                authProvider.isAnonymous 
                    ? 'Guest User' 
                    : authProvider.currentUser?.email ?? 'User',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                authProvider.isAnonymous
                    ? 'You are currently using the app as a guest'
                    : 'Signed in with email',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Account Status Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            authProvider.isAnonymous
                                ? Icons.person_outline
                                : Icons.verified_user,
                            color: authProvider.isAnonymous
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.isAnonymous
                                      ? 'Guest Account'
                                      : 'Verified Account',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  authProvider.isAnonymous
                                      ? 'Your data is only stored on this device'
                                      : 'Your data is securely stored in the cloud',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Options List
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    if (authProvider.isAnonymous)
                      ListTile(
                        leading: Icon(
                          Icons.login,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('Sign In'),
                        subtitle: const Text('Create an account to save your data'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      )
                    else
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('Account Settings'),
                        subtitle: const Text('Update your account information'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to account settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account settings coming soon!'),
                            ),
                          );
                        },
                      ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Help & Support'),
                      subtitle: const Text('Get help with the app'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to help & support
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help & Support coming soon!'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('About'),
                      subtitle: const Text('Learn more about SmartSave'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to about
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('About page coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Sign Out Button
              if (!authProvider.isAnonymous)
                ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}