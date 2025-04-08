import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopBar extends StatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  // Track expanded state of menu items
  final Map<String, bool> _expandedItems = {
    'Profile': false,
    'Quiz': false,
    'Rewards': false,
  };

  void _toggleExpanded(String key) {
    setState(() {
      _expandedItems[key] = !(_expandedItems[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF4A7DFF),
        child: SafeArea(
          child: Column(
            children: [
              // User profile section
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8E4FF),
                        border: Border.all(color: Colors.white, width: 2.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Image.asset(
                          'assets/images/avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 40.r, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Melikmemmed",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
              
              // Expandable menu items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile expandable section
                      _buildExpandableSection(
                        title: 'Profile',
                        icon: Icons.person,
                        children: [
                          _buildSubMenuItem(
                            title: 'View Profile',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to profile page
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Edit Profile',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to edit profile page
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Change Avatar',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to change avatar page
                            },
                          ),
                        ],
                      ),
                      
                      // Quiz expandable section
                      _buildExpandableSection(
                        title: 'Quiz',
                        icon: Icons.casino,
                        children: [
                          _buildSubMenuItem(
                            title: 'Quiz History',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to quiz history
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Leaderboard',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to leaderboard
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Achievements',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to achievements
                            },
                          ),
                        ],
                      ),
                      
                      // Rewards expandable section
                      _buildExpandableSection(
                        title: 'Rewards',
                        icon: Icons.card_giftcard,
                        children: [
                          _buildSubMenuItem(
                            title: 'Available Rewards',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to available rewards
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'My Purchases',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to purchases
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Redeem Code',
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to redeem code
                            },
                          ),
                        ],
                      ),
                      
                      // Non-expandable items
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to help and support
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: "About Us",
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to about us
                        },
                      ),
                      
                      // Statistics section
                      Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Statistics",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildStatItem(
                              icon: Icons.check_circle,
                              title: "Total Questions",
                              value: "1,234",
                            ),
                            SizedBox(height: 12.h),
                            _buildStatItem(
                              icon: Icons.emoji_events,
                              title: "Quiz Won",
                              value: "56",
                            ),
                            SizedBox(height: 12.h),
                            _buildStatItem(
                              icon: Icons.star,
                              title: "Accuracy",
                              value: "76%",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom buttons
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.settings, color: Colors.white, size: 24.r),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Logout action
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.exit_to_app, color: Colors.white, size: 24.r),
                      ),
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

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedItems[title] ?? false;
    
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white, size: 24.r),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 24.r,
          ),
          onTap: () => _toggleExpanded(title),
        ),
        if (isExpanded)
          Column(children: children),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 56.w, right: 16.w),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14.sp,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24.r),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.r),
      onTap: onTap,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20.r),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}