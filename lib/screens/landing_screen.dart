import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/family_member.dart';
import '../services/database_service.dart';
import '../utils/image_helper.dart';
import 'dashboard_screen.dart';
import 'lists_screen.dart';
import 'location_screen.dart';
import 'calendar_screen.dart';
import 'my_profile_screen.dart';

// Landing screen with navigation buttons
class LandingScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const LandingScreen({super.key, this.onLogout});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final DatabaseService _dbService = DatabaseService();
  FamilyMember? _selfMember;

  @override
  void initState() {
    super.initState();
    _loadSelfMember();
  }

  // Load self member for profile image display
  Future<void> _loadSelfMember() async {
    try {
      final selfMember = await _dbService.getSelfMember();
      if (mounted) {
        setState(() {
          _selfMember = selfMember;
        });
      }
    } catch (e) {
      // Silently fail - profile image is optional
    }
  }

  // Refresh self member when returning from profile screen
  Future<void> _refreshSelfMember() async {
    await _loadSelfMember();
  }

  // Navigate to my profile screen
  Future<void> _navigateToMyProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyProfileScreen(),
      ),
    );
    // Refresh profile image when returning
    _refreshSelfMember();
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
            'Are you sure you want to logout? You will need to authenticate again to access your family information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Navigate to members screen
  void _navigateToMembers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  // Navigate to lists screen
  void _navigateToLists(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListsScreen(),
      ),
    );
  }

  // Navigate to location screen
  void _navigateToLocation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationScreen(),
      ),
    );
  }

  // Navigate to calendar screen
  void _navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Family',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Profile image - clickable to open profile
          if (_selfMember != null && _selfMember!.profileImagePath != null)
            GestureDetector(
              onTap: _navigateToMyProfile,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(AppConstants.primaryColor),
                  backgroundImage: ImageHelper.getImageProvider(_selfMember!.profileImagePath!),
                ),
              ),
            )
          else if (_selfMember != null)
            GestureDetector(
              onTap: _navigateToMyProfile,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(AppConstants.primaryColor),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(AppConstants.textColor),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                _navigateToMyProfile();
              } else if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(AppConstants.primaryColor)),
                    SizedBox(width: 8),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              const SizedBox(height: 20),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.textColor),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose an option to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 32),

              // Navigation buttons grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Members button
                    _buildNavigationCard(
                      context,
                      icon: Icons.people,
                      title: 'Members',
                      subtitle: 'View and manage family members',
                      color: const Color(AppConstants.primaryColor),
                      onTap: () => _navigateToMembers(context),
                    ),

                    // Lists button
                    _buildNavigationCard(
                      context,
                      icon: Icons.list,
                      title: 'Lists',
                      subtitle: 'Manage your lists',
                      color: const Color(AppConstants.secondaryColor),
                      onTap: () => _navigateToLists(context),
                    ),

                    // Location button
                    _buildNavigationCard(
                      context,
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'View locations on map',
                      color: const Color(AppConstants.successColor),
                      onTap: () => _navigateToLocation(context),
                    ),

                    // Calendar button
                    _buildNavigationCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Calendar',
                      subtitle: 'View and manage events',
                      color: const Color(AppConstants.calendarColor),
                      onTap: () => _navigateToCalendar(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build navigation card
  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
